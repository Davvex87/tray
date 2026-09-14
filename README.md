# tray

hxcpp externs for [webview/tray](https://github.com/webview/tray) to create a system tray icon with a popup menu, for Windows, MacOS and Linux, for usage in Haxe applications and services with ease.

## Usage

```haxe
import tray.Tray;
import tray.TrayMenuDef;
import tray.TrayMenuItem;

class Main
{
    static function main()
    {

        function subItemCb(item:TrayMenuItem)
            trace(item.text);

        var tray = new Tray("icon.ico",
        [
            TrayButton("Hello", item -> {
                item.text = "Hi again";   // items are mutable, change me!
                Tray.current.update();
            }),

            TrayToggle("Enabled", true, item -> trace('enabled = ${item.checked}')),

            TraySubmenu("More", [
                TrayButton("Sub item A", subItemCb),
                TrayButton("Sub item B", subItemCb),
            ]),

            TraySeparator,

            TrayButton("Quit", _ -> Tray.current.exit()),
        ]);

        if (!tray.init()) throw "tray init failed";
        tray.run();
        // code down here still runs, the process only dies once the tray exits,
        // unless you pass `true` as the first argument to `tray.run()`

    }
}
```

## Items

```haxe
TrayButton(text:String, onClick:TrayMenuItem->Void, ?disabled:Bool);
TrayToggle(text:String, checked:Bool, ?onChange:TrayMenuItem->Void, ?disabled:Bool);
TraySubmenu(text:String, items:Array<TrayMenuDef>, ?disabled:Bool);
TraySeparator;
```

## License

`webview/tray` is licensed under MIT.

These hxcpp externs are under MIT too.
