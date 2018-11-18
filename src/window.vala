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
	// public class PostModel : GLib.Object {
	//     public string title;

 //        public PostModel(string title) {
 //            this.title = title;
 //        }

 //    }

	[GtkTemplate (ui = "/org/gnome/Reddit-App/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		[GtkChild]
		private Hdy.Leaflet header;

		[GtkChild]
		private Gtk.ListBox post_list;

		[GtkChild]
		private Gtk.Stack content;

		private GLib.ListStore post_list_store;

		public Window (Gtk.Application app) {
			Object (application: app);

		    var api = RedditApp.Api.instance();
		    api.loadFrontPage();

            post_list_store = new GLib.ListStore(GLib.Type.OBJECT);
		    post_list.bind_model((GLib.ListModel) this.post_list_store, (item) => {
                return new Gtk.Label("foobar");
		    });
		    post_list_store.append(new RedditApp.PostModel("adam"));

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
		public void on_back_clicked () {
			header.visible_child_name = "sidebar";
		}

		[GtkCallback]
		public void on_show_content_clicked () {
			header.visible_child_name = "content";
		    content.set_visible_child_name("front_page");
		    stdout.printf("\nthe content clicked was called \n\n");
		}
	}
}
