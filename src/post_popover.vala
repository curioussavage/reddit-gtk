using Gtk;


namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/post_popover.ui")]
	public class PostPopover : Gtk.Popover {
	    [GtkChild]
	    public Gtk.Button sub_button;

	    [GtkChild]
	    public Gtk.Button user_button;

	}
}
