using Gtk;
using GLib;
//using Gdk;

public class TextFileViewer : Gtk.Window {

    private TextView textbox;
	private Fixed fixed;
	private VBox vbox;
	private ScrolledWindow scrolled;
	private Alignment align;
	private EventBox boxout;
	private EventBox boxin;
	

    public TextFileViewer () {
        this.title = "Text File Viewer";
        this.position = WindowPosition.CENTER;
        set_default_size (400, 300);

        this.textbox = new TextView ();
        this.textbox.editable = true;
        this.textbox.cursor_visible = true;
		this.textbox.set_wrap_mode (WrapMode.WORD);
        this.textbox.scroll_event.connect (on_scroll_event);

		this.fixed = new Fixed ();
		this.vbox = new VBox (false, 0);
		this.align = new Alignment (0.5f, 0.5f, 0.5f, 0.5f);
		this.align.add (this.vbox);
		add (this.align);

		this.boxout = new EventBox ();
		this.boxout.set_border_width (1);
		this.boxin = new EventBox ();
		this.boxin.set_border_width (1);
		this.vbox.pack_start (this.boxout, true, true, 1);
		this.boxout.add (this.boxin);

		this.scrolled = new ScrolledWindow(null, null);
		this.boxin.add(this.scrolled);
		this.scrolled.add(this.textbox);
        this.scrolled.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		this.scrolled.show ();
		this.scrolled.set_property("resize_mode", ResizeMode.PARENT);
		this.textbox.set_property("resize_mode", ResizeMode.PARENT);
		this.vbox.set_property("resize_mode", ResizeMode.PARENT);
		this.vbox.show_all ();
			
		// Status     
    }

    private bool on_scroll_event (Gdk.EventScroll e) {
		if (e.direction == Gdk.ScrollDirection.UP) {
			stderr.printf ("We scrollin up breds");
			scroll_up ();
			
		}
		else if (e.direction == Gdk.ScrollDirection.DOWN) {
			stderr.printf("We scrollin down breds");
			scroll_down ();
		}
		
		return true;
    }

	private void scroll_up () {
		Adjustment adj = this.scrolled.get_vadjustment ();
		if (adj.value > adj.step_increment) {
			adj.value -= adj.step_increment;
		}
		else {
			adj.value = 0;
		}
	}

	private void scroll_down () {
		Adjustment adj = this.scrolled.get_vadjustment ();
		if (adj.upper > adj.page_size) {
			adj.value = Math.fmin (adj.upper - adj.page_size, adj.value + adj.step_increment);
		}
	}

    public static int main (string[] args) {
        Gtk.init (ref args);

        var window = new TextFileViewer ();
        window.destroy.connect (Gtk.main_quit);
        window.show_all ();

        Gtk.main ();
        return 0;
    }
}