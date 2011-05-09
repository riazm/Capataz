using Gtk;
using GLib;
//using Gdk;

public class FadeLabel : Gtk.Label {
	
	private int active_duration = 3000; // Fade starts after this time
	private int fade_duration = 1500;	// Fade lasts this long

	public FadeLabel (string message = "", string active_color = "", 
		string inactive_colour = "") {
		
		this.set_text(message);
		
		
		
	}
	
}

public class TextFileViewer : Gtk.Window {

    private Gtk.TextView textbox;
	private Gtk.ScrolledWindow scrolled;

    public TextFileViewer () {
		FadeLabel status = new FadeLabel("What");
		
        this.title = "Capataz";
        this.position = WindowPosition.CENTER;
        set_default_size (400, 300);

        textbox = new TextView ();
        textbox.editable = true;
        textbox.cursor_visible = true;
		textbox.set_wrap_mode (Gtk.WrapMode.WORD);
        textbox.scroll_event.connect (on_scroll_event);

		Gtk.Fixed fixed = new Gtk.Fixed ();
		Gtk.VBox vbox = new Gtk.VBox (false, 0);
		
		Gtk.Alignment alignment = new Alignment (0.5f, 0.5f, 0.5f, 0.5f);
		alignment.add (vbox);
		add (alignment);

		Gtk.EventBox boxout = new Gtk.EventBox ();
		boxout.set_border_width (1);
		
		Gtk.EventBox boxin = new Gtk.EventBox ();
		boxin.set_border_width (1);
		vbox.pack_start (boxout, true, true, 1);
		boxout.add (boxin);

		scrolled = new Gtk.ScrolledWindow(null, null);
		boxin.add(scrolled);
		scrolled.add(this.textbox);
        scrolled.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		scrolled.show ();
		scrolled.set_property("resize_mode", Gtk.ResizeMode.PARENT);
		textbox.set_property("resize_mode", Gtk.ResizeMode.PARENT);
		vbox.set_property("resize_mode", Gtk.ResizeMode.PARENT);
		vbox.show_all ();
			
		// Status     
		Gtk.HBox hbox = new Gtk.HBox(false, 0);
		hbox.set_spacing(12);
		hbox.pack_end(status, true, true, 0);
		vbox.pack_end(hbox, false, false, 0);
		status.set_alignment(0.0f, 0.5f);
		status.set_justify(Gtk.Justification.LEFT);
		
		
    }

    private bool on_scroll_event (Gdk.EventScroll e) {
		if (e.direction == Gdk.ScrollDirection.UP) {
			stderr.printf ("We scrollin up breds");
			scroll_up ();
			
		} else if (e.direction == Gdk.ScrollDirection.DOWN) {
			stderr.printf("We scrollin down breds");
			scroll_down ();
		}
		
		return true;
    }

	private void scroll_up () {
		Adjustment adj = this.scrolled.get_vadjustment ();
		if (adj.value > adj.step_increment) {
			adj.value -= adj.step_increment;
		} else {
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