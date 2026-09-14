#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#undef UNICODE
#undef _UNICODE
#define TRAY_WINAPI 1
#elif defined(__APPLE__)
#define TRAY_APPKIT 1
#elif defined(__linux__)
#define TRAY_APPINDICATOR 1
#endif

#include "tray.h"
#include "tray_glue.h"

struct hx_tray_menu {
	struct tray_menu *items; /* NULL-terminated once finalized */
	hx_tray_menu **subs;		 /* parallel to items; owned */
	int count;
	int cap;
	int finalized;
};

static struct tray g_tray;
static hx_tray_menu *g_menu = NULL;
static char *g_icon = NULL;
static hx_tray_cb g_cb = NULL;

static char *hx_strdup(const char *s)
{
	size_t n = strlen(s) + 1;
	char *p = (char *)malloc(n);
	if (p)
		memcpy(p, s, n);

	return p;
}

static void hx_tray_dispatch(struct tray_menu *m)
{
	int id = (int)(intptr_t)m->context;
	if (g_cb)
		g_cb(id);
}

hx_tray_menu *hx_tray_menu_new(void)
{
	hx_tray_menu *m = (hx_tray_menu *)calloc(1, sizeof(hx_tray_menu));
	return m;
}

static void menu_push(hx_tray_menu *menu, const char *text, int disabled, int checked, int toggle, int id, hx_tray_menu *sub) {
	if (menu == NULL || menu->finalized)
		return;
	
	if (menu->count + 1 >= menu->cap)
	{
		int ncap = menu->cap ? menu->cap * 2 : 8;
		menu->items = (struct tray_menu *)realloc(menu->items, ncap * sizeof(*menu->items));
		menu->subs = (hx_tray_menu **)realloc(menu->subs, ncap * sizeof(*menu->subs));
		menu->cap = ncap;
	}

	struct tray_menu *it = &menu->items[menu->count];
	memset(it, 0, sizeof(*it));

	it->text = hx_strdup(text ? text : "");
	it->disabled = disabled;
	it->checked = checked;
	it->toggle = toggle;
	it->cb = hx_tray_dispatch;
	it->context = (void *)(intptr_t)id;
	it->submenu = NULL;

	menu->subs[menu->count] = sub;
	menu->count++;
}

void hx_tray_menu_add(hx_tray_menu *menu, const char *text, int disabled, int checked, int toggle, int id)
{
	menu_push(menu, text, disabled, checked, toggle, id, NULL);
}

void hx_tray_menu_add_sub(hx_tray_menu *menu, const char *text, int disabled, int checked, int toggle, int id, hx_tray_menu *submenu)
{
	menu_push(menu, text, disabled, checked, toggle, id, submenu);
}

static void menu_finalize(hx_tray_menu *menu)
{
	if (menu == NULL || menu->finalized)
		return;

	if (menu->items == NULL)
	{
		menu->items = (struct tray_menu *)calloc(1, sizeof(*menu->items));
		menu->subs = (hx_tray_menu **)calloc(1, sizeof(*menu->subs));
		menu->cap = 1;
	}

	memset(&menu->items[menu->count], 0, sizeof(struct tray_menu));

	for (int i = 0; i < menu->count; i++)
	{
		if (menu->subs[i])
		{
			menu_finalize(menu->subs[i]);
			menu->items[i].submenu = menu->subs[i]->items;
		}
	}
	menu->finalized = 1;
}

void hx_tray_menu_free(hx_tray_menu *menu)
{
	if (menu == NULL)
		return;
	
	for (int i = 0; i < menu->count; i++)
	{
		free(menu->items[i].text);
		hx_tray_menu_free(menu->subs[i]);
	}

	free(menu->items);
	free(menu->subs);
	free(menu);
}

void hx_tray_set_callback(hx_tray_cb cb)
{
	g_cb = cb;
}

static void set_state(const char *icon, hx_tray_menu *menu)
{
	char *old_icon = g_icon;
	g_icon = hx_strdup(icon ? icon : "");
	g_tray.icon = g_icon;
	menu_finalize(menu);
	g_tray.menu = menu ? menu->items : NULL;
	free(old_icon);
}

int hx_tray_init(const char *icon, hx_tray_menu *menu)
{
	hx_tray_menu *old = g_menu;
	set_state(icon, menu);
	g_menu = menu;
	int rc = tray_init(&g_tray);
	hx_tray_menu_free(old);
	return rc;
}

void hx_tray_update(const char *icon, hx_tray_menu *menu)
{
	hx_tray_menu *old = g_menu;
	set_state(icon, menu);
	g_menu = menu;
	tray_update(&g_tray);
	hx_tray_menu_free(old);
}

int hx_tray_loop(int blocking)
{
	return tray_loop(blocking);
}

void hx_tray_exit(void)
{
	tray_exit();
	hx_tray_menu_free(g_menu);
	g_menu = NULL;
	g_tray.menu = NULL;
}
