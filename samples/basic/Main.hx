import tray.Tray;
import tray.TrayMenuDef;

class Main {
	static var clicks = 0;

	static function main()
	{
		var tray = new Tray(Sys.systemName() == "Windows" ? "icon.ico" : "icon.png", [
			TrayButton("Hello", _ -> Sys.println("Hello clicked")),
			TrayToggle("Toggle me", false, item -> Sys.println('toggle -> ${item.checked}')),
			TrayButton("Clicked: 0 times", item -> {
				clicks++;
				// Items are mutable: just change the text and refresh.
				item.text = 'Clicked: $clicks times';
				Sys.println('counter -> $clicks');
				Tray.current.update();
			}),
			TrayButton("Disabled item", _ -> throw "this shouldn't have fired, but it did", true),
			TraySubmenu("Submenu", [
				TrayButton("Sub item A", item -> Sys.println('${item.text} clicked')),
				TrayButton("Sub item B", item -> Sys.println('${item.text} clicked')),
			]),
			TraySeparator,
			TrayButton("Quit", _ -> {
				Sys.println("Quit clicked");
				Tray.current.exit();
			}),
		]);

		if (!tray.init())
		{
			Sys.println("tray.init() failed");
			Sys.exit(1);
		}
		
		Sys.println("Tray icon created. Right-click it and choose Quit to exit.");
		tray.run();
	}
}
