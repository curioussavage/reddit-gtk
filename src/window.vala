/* window.vala
 *
 * Copyright 2018 curioussavage
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace RedditApp {
	[GtkTemplate (ui = "/org/gnome/Reddit-App/window.ui")]
	public class Window : Gtk.ApplicationWindow {

		[GtkChild]
		private Gtk.ListBox post_list;

		[GtkChild]
		private Gtk.Stack content;

		[GtkChild]
		private Gtk.Box front_page;

		[GtkChild]
		private Gtk.ScrolledWindow comment_page;

		[GtkChild]
		private Gtk.ScrolledWindow subreddit_page;

		[GtkChild]
		private Gtk.ListBox comments_list;

		[GtkChild]
		private Gtk.Box comment_page_post_box;

		[GtkChild]
		private Gtk.ListBox subreddit_post_list;

		private GLib.ListStore post_list_store;

		public Window (Gtk.Application app) {
			Object (application: app);

			var store_instance = RedditApp.Store.get_instance();
			//  post_list_store = new GLib.ListStore(GLib.Type.OBJECT);
		    post_list.bind_model((GLib.ListModel) store_instance.post_list_store, (item) => {
		        return new RedditApp.RedditPost((RedditApp.PostModel) item);
			});

            subreddit_post_list.bind_model((GLib.ListModel) store_instance.subreddit_post_list_store, (item) => {
		        return new RedditApp.RedditPost((RedditApp.PostModel) item);
            });

            comments_list.bind_model(store_instance.comments_list_store, (item) => {
                return new RedditApp.RedditComment((RedditApp.CommentModel) item);
            });

            //store_instance.notify["current_page"].connect((s, Prop) => {
            store_instance.nav.connect((s, prop) => {
                //var val = RedditApp.Store.get_instance().current_page;
                switch(prop) {
                    case RedditApp.pages.FRONT:
                      content.visible_child_name = "front_page";
                      break;
                    case RedditApp.pages.COMMENTS:
                      // set post
                      var post = new RedditCardPost(store_instance.comments_page_post, true);

                      comment_page_post_box.add(post);
                      post.show();
                      content.visible_child_name = "comment_page";
                      break;
                    case RedditApp.pages.SUBREDDIT:
                      content.visible_child_name = "subreddit_page";
                      break;
                }
            });

			RedditApp.Controller.instance().load_front_page();

		}

		[GtkCallback]
		public bool on_key_pressed (Gdk.EventKey event) {
			var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

			if ((event.keyval == Gdk.Key.q || event.keyval == Gdk.Key.Q) &&
				(event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
				destroy ();

				return true;
			}

			return false;
		}

		[GtkCallback]
		public void on_header_click () {
		    content.visible_child_name = "subreddit_page";
		}

		[GtkCallback]
		private void on_subreddit_page_btn_click() {
		    content.visible_child_name = "front_page";
		}
	}
}
