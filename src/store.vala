using GLib;


namespace RedditApp {

    public enum pages {
        FRONT,
        SUBREDDIT,
        COMMENTS,
    }

    public class Store: GLib.Object {
        private static RedditApp.Store _instance;

        public signal void nav(RedditApp.pages page);
        //public RedditApp.pages current_page { get; set; default=RedditApp.pages.FRONT; }
        private RedditApp.pages _current_page = RedditApp.pages.FRONT;
        public RedditApp.pages current_page {
            get { return _current_page; }
            set { _current_page = value; nav(value); }
        }

        public string current_post;

        // for front page
        public GLib.ListStore post_list_store = new GLib.ListStore(GLib.Type.OBJECT);

        // for comments page
        public GLib.ListStore comments_list_store = new GLib.ListStore(GLib.Type.OBJECT);
        public RedditApp.PostModel comments_page_post;

        // subreddit pages
        public GLib.ListStore subreddit_post_list_store = new GLib.ListStore(GLib.Type.OBJECT);

        private Store() {
        }

        public static RedditApp.Store get_instance() {
            if (_instance == null) {
                _instance = new RedditApp.Store();
            }
            return _instance;
        }

    }
}
