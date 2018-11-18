using Gtk;


namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/window.ui")]
	public class RedditPost : Gtk.ListBoxRow {
		[GtkChild]
		private Gtk.Label post_title;
	}
}