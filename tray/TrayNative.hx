package tray;

import cpp.Callable;
import cpp.ConstCharStar;
import cpp.RawPointer;

@:native("hx_tray_menu")
@:include("tray_glue.h")
@:unreflective
extern class HxTrayMenu {}

@:include("tray_glue.h")
@:buildXml('
<files id="haxe">
	<compilerflag value="-I${haxelib:tray}/native" />
</files>

<files id="tray_glue" tags="haxe">
	<compilerflag value="-I${haxelib:tray}/native" />
	<section if="linux">
		<compilerflag value="-I/usr/include/gtk-3.0" />
		<compilerflag value="-I/usr/include/glib-2.0" />
		<compilerflag value="-I/usr/lib/x86_64-linux-gnu/glib-2.0/include" />
		<compilerflag value="-I/usr/lib/glib-2.0/include" />
		<compilerflag value="-I/usr/include/pango-1.0" />
		<compilerflag value="-I/usr/include/harfbuzz" />
		<compilerflag value="-I/usr/include/cairo" />
		<compilerflag value="-I/usr/include/gdk-pixbuf-2.0" />
		<compilerflag value="-I/usr/include/atk-1.0" />
		<compilerflag value="-I/usr/include/libappindicator3-0.1" />
	</section>
	<file name="${haxelib:tray}/native/tray_glue.c" />
</files>

<target id="haxe">
	<files id="tray_glue" />
	<section if="windows">
		<lib name="user32.lib" />
		<lib name="shell32.lib" />
	</section>
	<section if="mac">
		<vflag name="-framework" value="Cocoa" />
	</section>
	<section if="linux">
		<lib name="-lgtk-3" />
		<lib name="-lgdk-3" />
		<lib name="-lgobject-2.0" />
		<lib name="-lglib-2.0" />
		<lib name="-lappindicator3" />
	</section>
</target>
')
@:unreflective
extern class TrayNative
{
	@:native("hx_tray_menu_new")
	static function menuNew():RawPointer<HxTrayMenu>;

	@:native("hx_tray_menu_add")
	static function menuAdd(menu:RawPointer<HxTrayMenu>, text:ConstCharStar, disabled:Int, checked:Int, toggle:Int, id:Int):Void;

	@:native("hx_tray_menu_add_sub")
	static function menuAddSub(menu:RawPointer<HxTrayMenu>, text:ConstCharStar, disabled:Int, checked:Int, toggle:Int, id:Int, submenu:RawPointer<HxTrayMenu>):Void;

	@:native("hx_tray_menu_free")
	static function menuFree(menu:RawPointer<HxTrayMenu>):Void;

	@:native("hx_tray_set_callback")
	static function setCallback(cb:Callable<Int->Void>):Void;

	@:native("hx_tray_init")
	static function init(icon:ConstCharStar, menu:RawPointer<HxTrayMenu>):Int;

	@:native("hx_tray_update")
	static function update(icon:ConstCharStar, menu:RawPointer<HxTrayMenu>):Void;

	@:native("hx_tray_loop")
	static function loop(blocking:Int):Int;

	@:native("hx_tray_exit")
	static function exit():Void;
}
