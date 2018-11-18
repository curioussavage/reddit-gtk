using Soup;
using Json;
using GLib;
using Gtk;

const string front_page_url = "/hot.json";
const string api_base = "https://reddit.com";


namespace RedditApp {

    public delegate void StringCompletionHandler( uint statusCode, Message msg );

    public class Api: GLib.Object {
        private Soup.Session _session;
        private static GLib.Once<Api> _instance;

        public static unowned Api instance () {
            return _instance.once (() => { return new Api (); });
        }

        public Api() {
            _session = new Soup.Session();
        }

        // public void loadJsonForUrl( string url, StringCompletionHandler block) {
        //     var message = new Soup.Message("GET", url);
        //     assert( message != null );
        //     _session.send_message( message );
        //     print("GET %s => %u\n%s\n", url, message.status_code, (string) message.response_body.data);
        //     var rootnode = Json.from_string((string) message.response_body.data);
        //     block( message.status_code, rootnode);
        // }

        public void requestAsync( Message msg, SessionCallback block) {
            _session.queue_message (msg, (sess, mess) => {
                stdout.printf ("Message length: %lld\n%s\n",
                       mess.response_body.length,
                       mess.response_body.data);

                block(sess, mess);
            });
        }

        public void loadFrontPage() {
            // load front page here
            var message = new Soup.Message("GET", api_base + front_page_url);
            requestAsync(message, (sess, msg) => {
                stdout.printf("message recieved");
            });

        }
    }
}