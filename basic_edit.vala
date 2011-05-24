public class BasicEdit : GLib.Object {
	private TextFileViewer textfileviewer;
	public BasicEdit () {
		textfileviewer = new TextFileViewer ();
		FadeLabel status = textfileviewer.status;
		Gtk.Window window = textfileviewer.window;
//		window.add_accel_group(make_accel_group(self));
	}

	public static int main (string[] args) {
        Gtk.init (ref args);

        var window = new BasicEdit ();
        Gtk.main ();
        return 0;
    }
}
