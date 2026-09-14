#ifndef HX_TRAY_GLUE_H
#define HX_TRAY_GLUE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct hx_tray_menu hx_tray_menu;
typedef void (*hx_tray_cb)(int id);

hx_tray_menu *hx_tray_menu_new(void);
void hx_tray_menu_add(hx_tray_menu *menu, const char *text, int disabled, int checked, int id);
void hx_tray_menu_add_sub(hx_tray_menu *menu, const char *text, int disabled, int checked, int id, hx_tray_menu *submenu);

// Only needed if a built menu is never passed to init/update
void hx_tray_menu_free(hx_tray_menu *menu);

void hx_tray_set_callback(hx_tray_cb cb);

// Returns 0 on success, -1 on failure (or on the stub backend)
int hx_tray_init(const char *icon, hx_tray_menu *menu);
void hx_tray_update(const char *icon, hx_tray_menu *menu);

// Returns 0 while running, non-zero once hx_tray_exit() has been called
int hx_tray_loop(int blocking);
void hx_tray_exit(void);

#ifdef __cplusplus
}
#endif

#endif /* HX_TRAY_GLUE_H */
