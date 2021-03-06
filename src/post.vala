using Gtk;

using RedditApp;

namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/post.ui")]
	public class RedditPost : Gtk.ListBoxRow {
		[GtkChild]
		private Gtk.Label post_title;

		[GtkChild]
		private Gtk.Label post_metadata;

		[GtkChild]
		private Gtk.Image post_image;

		[GtkChild]
		private Gtk.Label post_vote_count;

		[GtkChild]
		private Gtk.Button comments_button;

		[GtkChild]
		private Gtk.MenuButton post_menu;

		private RedditApp.PostModel _model;

		private void handle_comments_page_click(Widget widget) {
            RedditApp.Controller.instance().loadCommentPage(this._model.id);
		}

		private void metadata_link_handler(Gtk.Widget widget, string uri) {
		    stdout.printf("\n uri is " + uri + "\n");
		}

		private Popover get_popover() {
		    RedditApp.PostPopover menu = new RedditApp.PostPopover();
		    //builder.add_from_file("/org/gnome/Reddit-App/post.ui");
		    menu.sub_button.label = "r/" + _model.subreddit;
		    menu.sub_button.clicked.connect(() => {
                // go to sub page
                RedditApp.Controller.instance().loadSubredditPage(this._model.id);
                stdout.printf("go to sub page \n\n");
		    });

		    menu.user_button.label = "u/" + _model.user;
		    // TODO go to user page;
		    return menu;
		}

		private void init(RedditApp.PostModel model, bool is_comment_page) {
		    if (is_comment_page) {
		        RedditApp.Store.get_instance().nav.connect((s, page) => {
		            if (page == RedditApp.pages.COMMENTS) {
		                destroy();
		            }
		        });
		    }
            this._model = model;

            // set up menu button
            post_menu.set_popover(get_popover());

			post_title.set_markup(@"<b>$(model.title)</b>");

            var tim = RedditApp.Utils.get_timestamp(model.created);
			var user = "u/" + model.user;
			var sub = "r/" + model.subreddit;
			var sub_link = @"<a href='#$(model.subreddit)'>$sub</a>";
			post_metadata.set_markup(sub_link + " " + user + " " + tim);
			post_metadata.set_halign(Align.START);
			post_metadata.connect("activate-link", metadata_link_handler);

			post_vote_count.label = model.vote_count.to_string();

			comments_button.clicked.connect(handle_comments_page_click);

			var filename = model.id;
			stdout.printf("model has thumb \n\n");
			stdout.printf(model.has_thumbnail.to_string());
			if (model.has_thumbnail) {
			    this.post_image.visible = true;
			    var file_path = Environment.get_home_dir () + "/.cache/reddit-app/media/" + filename;
			    GLib.File file = File.new_for_path (file_path);

			    if (file.query_exists ()) {
				    try {
					    var media_pixbuf = new Gdk.Pixbuf.from_file_at_scale ( // should use the thumbnail size info for this
						    file_path,
						    140, 140, true);
						var scaled = media_pixbuf.scale_simple(100, 100, Gdk.BILINEAR);
					    post_image.set_from_pixbuf(scaled);
				    } catch(Error e) {
					    stdout.printf("error in pic");
				    }
			    } else {
				    Utils.Downloader.get_instance().downloaded.connect((download) => {
						if (download.id == this._model.id) {
							var media_pixbuf = new Gdk.Pixbuf.from_file_at_scale (
								file_path,
								140, 140, true);
							var scaled = media_pixbuf.scale_simple(100, 100, Gdk.BILINEAR);
							post_image.set_from_pixbuf(scaled);
						}
				    });
			    }
			}
		}

		public RedditPost(RedditApp.PostModel model, bool is_comment_page=false) {
		    Object();
		    init(model, is_comment_page);
		}

	}
}
