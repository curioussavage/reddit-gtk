using Json;

namespace RedditApp {
	public class CommentModel : GLib.Object {
        public string id;
        public string author;
        public int64 vote_count;
        public string content;
        public int64 depth;

        public CommentModel(string id) {
            this.id = id;
        }

		public CommentModel.fromJson(Json.Object json) {
            this.id = json.get_string_member("id");
            this.author = json.get_string_member("author");
            this.vote_count = json.get_int_member("score");
            this.content = json.get_string_member("body");
            this.depth = json.get_int_member("depth");
		}
    }
}
