using Json;
using Soup;

namespace RedditApp {
    public class PreviewImage: GLib.Object {
        public string url;
        public int64 width;
        public int64 height;

        public PreviewImage(Json.Object json) {
            this.url = URI.normalize(json.get_string_member("url"), null);
            this.width = json.get_int_member("width");
            this.height = json.get_int_member("height");
        }
    }

	public class PostModel : GLib.Object {
        public string title;
        public string thumbnail;
        public bool has_thumbnail;
        public string id;
        public string subreddit;
        public string user;
        public int64 vote_count;
        public int64 created;
        public bool has_preview = false;
        public PreviewImage preview;

        public PostModel(string title) {
            this.title = title;
        }

		public PostModel.fromJson(Json.Object json) {
            //  this.title = json
            try {
                this.title = json.get_string_member("title");
                this.thumbnail = json.get_string_member("thumbnail");
                this.has_thumbnail = (this.thumbnail != "self" && this.thumbnail != "spoiler" && this.thumbnail != "default");

                this.id = json.get_string_member("id");
                this.subreddit = json.get_string_member("subreddit");
                this.user = json.get_string_member("author");
                this.vote_count = json.get_int_member("score");
                this.created = json.get_int_member("created");

                if (this.has_thumbnail && json.has_member("preview")) {
                    var source_json = json
                        .get_object_member("preview")
                        .get_array_member("images")
                        .get_object_element(0)
                        .get_object_member("source");
                    this.has_preview = true;
                    this.preview = new PreviewImage(source_json);
                }
            } catch( GLib.Error e) {
                stdout.printf(e.message);
            }

            var instance = Utils.Downloader.get_instance();
            string loc = Environment.get_home_dir () + "/.cache/reddit-app/media/" + this.id;
            var file = File.new_for_uri(thumbnail);
            instance.download.begin(this.id, file, loc);
		}
    }
}
