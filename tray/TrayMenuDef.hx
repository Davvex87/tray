package tray;

/**
	Declarative description of a tray menu. Used to build the menu structure with simple enums.
	```haxe
	var tray = new Tray("icon.ico", [
	    TrayButton("Hello", item -> item.text = "Hi again"),
	    TrayToggle("Enabled", true, item -> trace(item.checked)),
	    TraySeparator,
	    TrayButton("Quit", _ -> Tray.current.exit()),
	]);
	```
**/
enum TrayMenuDef {
	/**
		A plain clickable item.
	**/
	TrayButton(text:String, onClick:TrayMenuItem->Void, ?disabled:Bool);

	/**
		A checkable item. `checked` is flipped automatically on click, then
		`onChange` is called with the item, then the tray is refreshed.
	**/
	TrayToggle(text:String, checked:Bool, ?onChange:TrayMenuItem->Void, ?disabled:Bool);

	/**
		An item that opens a nested menu.
	**/
	TraySubmenu(text:String, items:Array<TrayMenuDef>, ?disabled:Bool);

	/**
		A horizontal separator line.
	**/
	TraySeparator;
}
