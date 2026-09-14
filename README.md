# tray

hxcpp externs for [webview/tray](https://github.com/webview/tray) — a
cross-platform, single-header C99 system tray icon with a popup menu.

## Usage

```haxe
import tray.Tray;
import tray.TrayMenuDef;

class Main {
    static function main() {
        var tray = new Tray("icon.ico", [
            TrayButton("Hello", item -> {
                item.text = "Hi again";   // items are mutable
                Tray.current.update();
            }),
            TrayToggle("Enabled", true, item -> trace('enabled = ${item.checked}')),
            TraySubmenu("More", [
                TrayButton("Sub item", item -> trace(item.text)),
            ]),
            TraySeparator,
            TrayButton("Quit", _ -> Tray.current.exit()),
        ]);

        if (!tray.init()) throw "tray init failed";
        tray.run();
        // code down here still runs, the process only dies once the tray exits
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

MIT. `native/tray.h` is © webview/tray contributors, see `native/LICENSE.tray`.
