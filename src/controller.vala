using GLib;
using Soup;

namespace RedditApp {

    public class Controller: GLib.Object {
        private static RedditApp.Controller _instance;

        private Controller() {
            RedditApp.Api.instance().got_data.connect(handle_api_got_data);
        }

        public static Controller instance() {
            if (_instance == null) {
                _instance = new RedditApp.Controller();
            }
            return _instance;
        }

        private void handle_api_got_data(Message msg, RedditApp.pages type) {
            switch (type) {
                case RedditApp.pages.FRONT:
                    handle_front_page_got_data(msg);
                    break;
                case RedditApp.pages.COMMENTS:
                    handle_comment_page_got_data(msg);
                    break;
                case RedditApp.pages.SUBREDDIT:
                    handle_subreddit_page_got_data(msg);
                    break;
                default:
                    stdout.printf("not a recognized page");
                    break;
            }

        }

        delegate void ParsePostCb(Json.Object post_json);
        private void parse_post_listing(string json, ParsePostCb cb) {
            stdout.printf("trying to get json");
            try {
                var rootnode = Json.from_string( json );
                var json_response = rootnode.get_object();
                var data = json_response.get_object_member("data");
                var children = data.get_array_member("children");
                children.foreach_element((arr, index, node) => {
                    var obj = node.get_object();
                    if (!obj.has_member("data")) {
                        stdout.printf("oops this object does not have a 'data' field");
                        return;
                    }
                    var post_json = obj.get_object_member("data");
                    cb(post_json);
                });
            } catch (GLib.Error e) {
                stdout.printf(e.message);
            }
        }

        private void handle_front_page_got_data(Message msg) {
            try {
                    var store = RedditApp.Store.get_instance();
                    parse_post_listing((string) msg.response_body.data, (post_json) => {
                        var post_model = new RedditApp.PostModel.fromJson(post_json);
                        store.post_list_store.append(post_model);
                    });
                } catch(GLib.Error e) {
                    stdout.printf(e.message);
                }
        }

        public void load_front_page() {
            RedditApp.Api.instance().loadFrontPage();
        }

        public void loadCommentPage(string post_id) {
            RedditApp.Api.instance().loadCommentPage(post_id);
        }

        public void loadSubredditPage(string subreddit_name) {
            // TODO make it send them to the page here and display a loading state
            RedditApp.Api.instance().loadSubredditPage(subreddit_name);
        }

        private void handle_subreddit_page_got_data(Message msg ) {
            // send to page
            var store = RedditApp.Store.get_instance();
            stdout.printf("attempting to parse subreddit posts \n");
            parse_post_listing((string) msg.response_body.data, (post_json) => {
                stdout.printf("parsing post");
                // for some reason we only get two posts here and it fails
                var post_model = new RedditApp.PostModel.fromJson(post_json);
                store.subreddit_post_list_store.append(post_model);
            });
            RedditApp.Store.get_instance().current_page = RedditApp.pages.SUBREDDIT;
        }

        private void handle_comment_page_got_data(Message msg) {
            stdout.printf("got data sent");
            var rootnode = Json.from_string( (string) msg.response_body.data );
            var json_response = rootnode.get_array();

            var post_obj = json_response
              .get_object_element(0)
              .get_object_member("data")
              .get_array_member("children")
              .get_object_element(0)
              .get_object_member("data");
            var comments_array = json_response.get_object_element(1)
              .get_object_member("data")
              .get_array_member("children");

            // insert into store
            try {
                RedditApp.Store.get_instance().comments_page_post = new RedditApp.PostModel.fromJson(post_obj);
            } catch (GLib.Error e) {
                stdout.printf("error with post");
            }
            try {
                RedditApp.Store.get_instance().comments_list_store.remove_all();
                comments_array.foreach_element((array, index, node) => {
                    //stdout.printf("comment: \n\n -------------------- \n");
                    //stdout.printf(node.get_node_type().to_string());
                    var root = node.get_object();
                    var json = root.get_object_member("data");
                    var kind = root.get_string_member("kind");
                    if (kind == "more") {
                        // could be a continue thread model too.
                        // continue thread models have id "_"
                        // the parent_id must be used to link to the permalink page
                        //stdout.printf("loadmore found");

                    } else {
                        RedditApp.Store.get_instance().comments_list_store.append(new RedditApp.CommentModel.fromJson(json));
                    }
                });
            } catch (GLib.Error e) {
                stdout.printf("error with comment");
            }
            // switch stack to comments page
            RedditApp.Store.get_instance().current_page = RedditApp.pages.COMMENTS; // the notify signal is not being received :
        }
    }
}
