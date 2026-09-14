package tray;

import tray.TrayMenuDef;

class TrayMenuItem {
	/**
		Label shown in the menu. The special value `"-"` renders a separator.
	**/
	public var text:String;

	/**
		Greyed out and not clickable when `true`.
	**/
	public var disabled:Bool = false;

	/**
		Shows a check mark when `true`.
	**/
	public var checked:Bool = false;

	/**
		When `true` (items created from `TrayToggle`), a click flips `checked` and refreshes the tray before `onClick` is invoked.
	**/
	public var toggle:Bool = false;

	/**
		Called with this item when it is clicked.
	**/
	public var onClick:Null<TrayMenuItem->Void>;

	/**
		Nested menu.
		When set, the item opens a submenu instead of firing `onClick`.
	**/
	public var submenu:Null<Array<TrayMenuItem>>;

	public function new(text:String, ?onClick:TrayMenuItem->Void, ?submenu:Array<TrayMenuItem>)
	{
		this.text = text;
		this.onClick = onClick;
		this.submenu = submenu;
	}

	/**
		`true` if this item is a separator line.
	**/
	public var isSeparator(get, never):Bool;

	inline function get_isSeparator():Bool
		return text == "-";

	public static function fromDef(def:TrayMenuDef):TrayMenuItem
	{
		return switch (def) {
			case TrayButton(text, onClick, disabled):
				var item = new TrayMenuItem(text, onClick);
				item.disabled = disabled == true;
				item;
			case TrayToggle(text, checked, onChange, disabled):
				var item = new TrayMenuItem(text, onChange);
				item.checked = checked;
				item.toggle = true;
				item.disabled = disabled == true;
				item;
			case TraySubmenu(text, items, disabled):
				var item = new TrayMenuItem(text, null, fromDefs(items));
				item.disabled = disabled == true;
				item;
			case TraySeparator:
				new TrayMenuItem("-");
		}
	}

	public static function fromDefs(defs:Array<TrayMenuDef>):Array<TrayMenuItem>
	{
		return [for (d in defs) fromDef(d)];
	}
}
