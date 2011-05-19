public class TextFileViewer : Gtk.Window {

    private Gtk.TextView textbox;
	private Gtk.ScrolledWindow scrolled;
	private Gtk.VBox vbox;
	private Gtk.HBox hbox;
	private Gtk.EventBox boxout;
	private Gtk.EventBox boxin;
	private Gtk.Alignment alignment;
	private FadeLabel status;

    public TextFileViewer () {
		status = new FadeLabel();
		status.set_text("Initialised", 500);
        this.title = "Capataz";
//		this.fullscreen();

        textbox = new Gtk.TextView ();
        textbox.editable = true;
        textbox.cursor_visible = true;
		textbox.set_wrap_mode (Gtk.WrapMode.WORD);
        textbox.scroll_event.connect (on_scroll_event);

		vbox = new Gtk.VBox (false, 0);
		
		alignment = new Gtk.Alignment (0.5f, 0.5f, 0.0f, 0.0f);
		alignment.add (vbox);
		add (alignment);

		boxout = new Gtk.EventBox ();
		boxout.set_border_width (1);
		
		boxin = new Gtk.EventBox ();
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

		apply_config();
		apply_theme("default.theme");
		
		
    }
	private void apply_config () {
	
		GLib.KeyFile config_key = new GLib.KeyFile ();
		string config_path;
		string[] config_dirs = {GLib.Environment.get_home_dir(), "."};
		try {
			config_key.load_from_dirs("capataz.conf", config_dirs, 
				out config_path, GLib.KeyFileFlags.NONE);
			// TODO get a default when it fails or osmething
		} catch (GLib.KeyFileError key_file_error) {
			GLib.error("Something wrong with" + config_path);
		} catch (GLib.FileError file_error) {
			GLib.error("Couldn't load " + config_path);
		}
		
		if (config_key.get_integer("visual", "showborder") == 0) {
			this.boxin.set_border_width(0);
			this.boxout.set_border_width(0);
		} else {
			this.boxin.set_border_width(1);
			this.boxout.set_border_width(1);
		}

		// This seems sketch, I've not tested it for non custom fonts
		string new_font;
		string use_font_type = config_key.get_string("visual", "use_font_type");
		if ((use_font_type == "custom")) {
			new_font = config_key.get_string("visual", "custom_font");
		} else {
			new_font = config_key.get_string("visual", "use_font_type");
		}
		Pango.FontDescription font_description = Pango.FontDescription.from_string(new_font);
		this.textbox.modify_font(font_description);

		if (config_key.get_integer("visual", "indent") == 1) {
			Pango.Context pango_context = this.textbox.get_pango_context();
			font_description = pango_context.get_font_description();
			int current_font_size = font_description.get_size() / 1024;
			this.textbox.set_indent(current_font_size * 2);
		} else {
			this.textbox.set_indent(0);
		}
		
		int linespacing = config_key.get_integer("visual", "linespacing");
        this.textbox.set_pixels_below_lines(linespacing);
        this.textbox.set_pixels_above_lines(linespacing);
        this.textbox.set_pixels_inside_wrap(linespacing);

		this.alignment.set(0.5f, (float)config_key.get_double("visual", "alignment"), 0f, 0f);
	}

	private bool apply_theme (string theme) {
		GLib.KeyFile theme_key = new GLib.KeyFile (); 
		string[] theme_dirs = {"./themes/"};
		string theme_full_path;
		try {
			theme_key.load_from_dirs (theme, theme_dirs, out theme_full_path, GLib.KeyFileFlags.NONE);
		} catch (GLib.KeyFileError key_file_error) {
			stderr.printf("Something wrong with " + theme_full_path + "\n");
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
			GLib.message ("We scrollin up breds");
			scroll_up ();
			
		} else if (e.direction == Gdk.ScrollDirection.DOWN) {
			GLib.message ("We scrollin down breds");
			scroll_down ();
		}
		
		return true;
    }

	private void scroll_up () {
		Gtk.Adjustment adj = this.scrolled.get_vadjustment ();
		if (adj.value > adj.step_increment) {
			adj.value -= adj.step_increment;
		} else {
			adj.value = 0;
		}
	}

	private void scroll_down () {
		Gtk.Adjustment adj = this.scrolled.get_vadjustment ();
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