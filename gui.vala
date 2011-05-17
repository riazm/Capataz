using Gtk;


public class FadeLabel : Gtk.Label {
	
	private int active_duration = 3000; // Fade starts after this time
	private int fade_duration = 1500;	// Fade lasts this long
	private double fade_level = 0;
	private uint idle = 0;
	public string active_colour = "#ffffff";
	public string inactive_colour = "#000000";

	public FadeLabel (string message = "", string active_colour = "", 
		string inactive_colour = "") {
		
		this.set_text(message);

		if (active_colour == "") {
			active_colour = "#ffffff";
		} else {
			this.active_colour = active_colour;
		}

		if (inactive_colour == "") {
			inactive_colour = "#000000";
		} else {
			this.inactive_colour = inactive_colour;
		}
	}

	public new void set_text (string message, int duration = 0) {
		/*Change the displayed text
		  string message: message to display
		  int duration: duration in milliseconds*/
		if (duration == 0) {
			duration = this.active_duration;
		}

		Gdk.Color colour;
		Gdk.Color.parse(this.active_colour, out colour);
		modify_fg(Gtk.StateType.NORMAL, colour);
		(this as Gtk.Label).set_text(message);
		if (this.idle != 0) {
			Source.remove(this.idle);
		}
		this.idle = Timeout.add(duration, this.fade_start);
	}
	
	public bool fade_start () {
		stderr.printf("starting a fade");
		this.fade_level = 1;
		if (this.idle != 0) {
			Source.remove(this.idle);
		}
		this.idle = Timeout.add(25, this.fade_out);
		return true;
	}

	public bool fade_out () {
		Gdk.Color colour;
		Gdk.Color.parse(this.inactive_colour, out colour);
		uint16 red1 = colour.red;
		uint16 green1 = colour.green;
		uint16 blue1 = colour.blue;

		Gdk.Color.parse(this.active_colour, out colour);
		uint16 red2 = colour.red;
		uint16 green2 = colour.green;
		uint16 blue2 = colour.blue;

		colour.red = red1 + (uint16)(this.fade_level * (red2 - red1));
		colour.green = green1 + (uint16)(this.fade_level * (green2 - green1));
		colour.blue = blue1 + (uint16)(this.fade_level * (blue2 - blue1));

		modify_fg(Gtk.StateType.NORMAL, colour);

		this.fade_level -= 1.0 / (this.fade_duration / 25);
		if (this.fade_level > 0) {
			return true;
		}
		this.idle = 0;
		return false;
	}
}

public class TextFileViewer : Gtk.Window {

    private Gtk.TextView textbox;
	private Gtk.ScrolledWindow scrolled;
	private Gtk.VBox vbox;
	private Gtk.HBox hbox;
	private Gtk.EventBox boxout;
	private FadeLabel status;

    public TextFileViewer () {
		status = new FadeLabel();
		status.set_text("Initialised", 500);
        this.title = "Capataz";

        textbox = new TextView ();
        textbox.editable = true;
        textbox.cursor_visible = true;
		textbox.set_wrap_mode (Gtk.WrapMode.WORD);
        textbox.scroll_event.connect (on_scroll_event);

		Gtk.Fixed fixed = new Gtk.Fixed ();
		vbox = new Gtk.VBox (false, 0);
		
		Gtk.Alignment alignment = new Alignment (0.5f, 0.5f, 0.5f, 0.5f);
		alignment.add (vbox);
		add (alignment);

		boxout = new Gtk.EventBox ();
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
		hbox = new Gtk.HBox(false, 0);
		hbox.set_spacing(12);
		hbox.pack_end(status, true, true, 0);
		vbox.pack_end(hbox, false, false, 0);
		status.set_alignment(0.0f, 0.5f);
		status.set_justify(Gtk.Justification.LEFT);

		apply_theme("default.theme");
		
		
    }

	private bool apply_theme (string theme) {
		GLib.KeyFile theme_key = new GLib.KeyFile (); 
		string[] theme_dirs = {"./themes/"};
		string theme_full_path;
		try {
			theme_key.load_from_dirs (theme, theme_dirs, out theme_full_path, GLib.KeyFileFlags.NONE);
		} catch (GLib.KeyFileError key_file_error) {
			stderr.printf("Something wrong with the KeyFile\n");
		} catch (GLib.FileError file_error) {
			stderr.printf("Something wrong with finding the theme file\n");
		}
		
		this.textbox.set_border_width (theme_key.get_integer ("theme", "padding"));
		
		Gdk.Screen screen = Gdk.Screen.get_default ();
		Gdk.Window root_window = screen.get_root_window ();
		
		int mouse_x;
		int mouse_y;
		Gdk.ModifierType mouse_mods;
		root_window.get_pointer (out mouse_x, out mouse_y, out mouse_mods);
		
		int current_monitor_number = screen.get_monitor_at_point(mouse_x, mouse_y);
		Gdk.Rectangle monitor_geometry;
		screen.get_monitor_geometry(current_monitor_number, out monitor_geometry);
		
		double width_percentage = theme_key.get_double ("theme", "width");
		double height_percentage = theme_key.get_double ("theme", "height");
		int vbox_width = (int)(width_percentage * monitor_geometry.width);
		int vbox_height = (int)(height_percentage * monitor_geometry.height);
		stderr.printf("%d, %d", vbox_width, vbox_height);
		this.vbox.set_size_request(vbox_width, vbox_height);

		this.modify_bg(Gtk.StateType.NORMAL, parse_colour(theme_key, "background")); 
		boxout.modify_bg(Gtk.StateType.NORMAL, parse_colour(theme_key, "border"));

		status.active_colour = theme_key.get_string("theme", "foreground");
		status.inactive_colour = theme_key.get_string("theme", "background");

		textbox.modify_bg(Gtk.StateType.NORMAL, parse_colour(theme_key, "textboxbg"));
		textbox.modify_base(Gtk.StateType.NORMAL, parse_colour(theme_key, "textboxbg"));
		textbox.modify_base(Gtk.StateType.SELECTED, parse_colour(theme_key, "foreground"));
		textbox.modify_text(Gtk.StateType.NORMAL, parse_colour(theme_key, "foreground"));
		textbox.modify_text(Gtk.StateType.SELECTED, parse_colour(theme_key, "textboxbg"));
		textbox.modify_fg(Gtk.StateType.NORMAL, parse_colour(theme_key, "foreground"));

		
		return false;
	}
	
	private Gdk.Color parse_colour(GLib.KeyFile theme_key, string key) {
		Gdk.Color colour;
		Gdk.Color.parse(theme_key.get_string("theme", key), out colour);
		return colour;
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