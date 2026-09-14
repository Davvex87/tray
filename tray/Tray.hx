package tray;

import cpp.Callable;
import cpp.ConstCharStar;
import cpp.RawPointer;
import tray.TrayMenuDef;
import tray.TrayMenuItem;
import tray.TrayNative.HxTrayMenu;

/**
	## Tray
	System tray icon with a popup menu.

	The underlying C library keeps a single global tray, so only one `Tray`
	may be initialised at a time, it is exposed as `Tray.current`.

	### Usage:
	```haxe
	var tray = new Tray("icon.ico", [
	    TrayButton("Hello", item -> item.text = "Hi again"),
	    TrayToggle("Enabled", true, item -> trace(item.checked)),
	    TraySeparator,
	    TrayButton("Quit", _ -> Tray.current.exit()),
	]);
	if (tray.init()) tray.run();
	```
**/
class Tray
{
	/**
		The tray that is currently initialised, or `null`.
	**/
	public static var current(default, null):Null<Tray>;

	/**
		Path to the icon file.
		
		- Windows expects an `.ico`;
		- MacOS an image name resolvable by `NSImage.imageNamed:`;
		- Linux a themed icon name, or a path to a PNG/SVG (its directory is
		  registered as the indicator's icon theme path).

		Call `update()` after changing it.
	**/
	public var icon:String;

	/**
		Top-level menu items (mutable). Change an item's `text`, `checked` or
		`disabled`, or edit the array, then call `update()`.
	**/
	public var menu:Array<TrayMenuItem>;

	/**
		`true` between a successful `init()` and `exit()`.
	**/
	public var initialized(default, null):Bool = false;

	/**
		Every item in the current native menu.
	**/
	var items:Array<TrayMenuItem> = [];

	/**
		The `MainLoop` event driving the non-blocking `run()`, if any.
	**/
	var mainEvent:Null<haxe.MainLoop.MainEvent>;

	public function new(icon:String, ?menu:Array<TrayMenuDef>)
	{
		this.icon = icon;
		this.menu = menu != null ? TrayMenuItem.fromDefs(menu) : [];
	}

	/**
		Replaces the whole menu from declarative defs. Call `update()` afterwards if already initialised.
	**/
	public function setMenu(defs:Array<TrayMenuDef>):Void
	{
		menu = TrayMenuItem.fromDefs(defs);
	}

	/**
		Creates the native tray icon. Returns `false` if the platform backend
		failed to initialise (or another `Tray` is already active).
	**/
	public function init():Bool
	{
		if (current != null && current != this)
			return false;
		current = this;

		TrayNative.setCallback(Callable.fromStaticFunction(dispatch));

		var rc = TrayNative.init(ConstCharStar.fromString(icon), buildMenu());
		initialized = rc == 0;

		if (!initialized)
			current = null;

		return initialized;
	}

	/**
		Rebuilds the native menu and icon from the current `icon` and `menu`.
	**/
	public function update():Void
	{
		if (!initialized)
			return;

		TrayNative.update(ConstCharStar.fromString(icon), buildMenu());
	}

	/**
		Pumps one iteration of the native event loop. Returns `true` while the
		tray is alive and `false` once `exit()` has been processed.
		With `blocking = true` the call waits for the next event.
	**/
	public function loop(blocking:Bool = true):Bool
	{
		return TrayNative.loop(blocking ? 1 : 0) == 0;
	}

	/**
		Runs the event loop until `exit()` is called.

		With `blocking = true` this parks the caller in a `while` loop.
		Otherwise it registers a `haxe.MainLoop` event that pumps the tray
		non-blockingly on every loop cycle, so the caller returns immediately
		and the rest of the program keeps running.
	**/
	public function run(blocking:Bool = false):Void
	{
		if (blocking)
			while (loop(true)) {}
		else
		{
			mainEvent = haxe.MainLoop.add(() -> {
				if (!loop(false) && mainEvent != null)
				{
					mainEvent.stop();
					mainEvent = null;
				}
			});
		}
	}

	/**
		Removes the tray icon and makes `loop()` return `false`.
	**/
	public function exit():Void
	{
		if (!initialized)
			return;

		TrayNative.exit();
		initialized = false;
		items = [];
		if (current == this)
			current = null;

		if (mainEvent != null)
		{
			mainEvent.stop();
			mainEvent = null;
		}
	}

	function buildMenu():RawPointer<HxTrayMenu>
	{
		items = [];
		return buildList(menu);
	}

	function buildList(list:Array<TrayMenuItem>):RawPointer<HxTrayMenu>
	{
		var native = TrayNative.menuNew();

		for (item in list)
		{
			var id = items.length;
			items.push(item);

			var text = ConstCharStar.fromString(item.text);
			var disabled = item.disabled ? 1 : 0;
			var checked = item.checked ? 1 : 0;
			var toggle = item.toggle ? 1 : 0;

			if (item.submenu != null)
				TrayNative.menuAddSub(native, text, disabled, checked, toggle, id, buildList(item.submenu));
			else
				TrayNative.menuAdd(native, text, disabled, checked, toggle, id);
		}

		return native;
	}

	static function dispatch(id:Int):Void
	{
		var tray = current;
		if (tray == null)
			return;

		var item = tray.items[id];
		if (item == null || item.submenu != null || item.isSeparator)
			return;

		if (item.toggle)
			item.checked = !item.checked;

		if (item.onClick != null)
			item.onClick(item);
		
		if (item.toggle)
			tray.update();
	}
}
