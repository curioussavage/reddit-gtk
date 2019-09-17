using Gtk;


namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/comment.ui")]
	public class RedditComment : Gtk.ListBoxRow {
	    private RedditApp.CommentModel _model;

		[GtkChild]
		private Gtk.TextView comment_body;

		[GtkChild]
		private Gtk.Label comment_author;

		[GtkChild]
		private Gtk.Label comment_vote_count;

		public RedditComment(RedditApp.CommentModel model) {
		   this._model = model;

		   comment_body.buffer.text = model.content;
		   comment_author.label = model.author;
		   comment_vote_count.label = model.vote_count.to_string();
		   if (model.depth > 0) {
		       this.margin_left = (int) model.depth * 15;
		   }
		}

	}
}
