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
