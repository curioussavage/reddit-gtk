using Gtk;

using RedditApp;

namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/cardpost.ui")]
	public class RedditCardPost : Gtk.ListBoxRow {
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

			var filename = model.id + "-preview";
			if (model.has_preview) {
                // download it
                var instance = Utils.Downloader.get_instance();
                string loc = Environment.get_home_dir() + "/.cache/reddit-app/media/" + filename;
				var file = File.new_for_uri(this._model.preview.url);
				stdout.printf("\nurl is: ");
				stdout.printf(this._model.preview.url);
				stdout.printf("\n" + Soup.URI.decode(this._model.preview.url) + "\n");
                instance.download.begin(filename, file, loc);

                // display it
                instance.downloaded.connect((download) => {
                    if (download.id == filename) {
                        stdout.printf("\n\ndownloaded comment page image \n\n");
                        //display
                        this.post_image.visible = true;
                        GLib.File downloaded_file = File.new_for_path (loc);

                        stdout.printf("checking if file at " + loc + " exists\n");
                        if (downloaded_file.query_exists ()) {
                            stdout.printf("the preview image exists yay");
                            try {
                                var media_pixbuf = new Gdk.Pixbuf.from_file_at_scale(
                                    loc, (int) this._model.preview.width, (int) this._model.preview.height, true
								);
								var width = this.get_allocated_width();
								var height = (width * (int) this._model.preview.height) / this._model.preview.width;

                                var scaled = media_pixbuf.scale_simple(width, (int) height, Gdk.BILINEAR);
                                post_image.set_from_pixbuf(scaled);
                                post_image.show();
                            } catch(Error e) {
                                stdout.printf("error in pic");
                            }
                        }
                    }
                });
			}
		}

		public RedditCardPost(RedditApp.PostModel model, bool is_comment_page=false) {
		    Object();
		    init(model, is_comment_page);
		}

	}
}

