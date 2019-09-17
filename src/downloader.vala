namespace RedditApp.Utils {
    public class Download {
        public string uri;
        public File cached_file;
        public string id;

        public Download (string id, string uri, File cached_file) {
            this.id = id;
            this.uri = uri;
            this.cached_file = cached_file;
        }
    }

    public class Downloader : GLib.Object {
        private static Downloader downloader;
        private Soup.SessionAsync session;

        private GLib.HashTable<string,Download> downloads;

        public signal void downloaded (Download download);
        public signal void download_failed (Download download, GLib.Error error);

        public static Downloader get_instance () {
            if (downloader == null)
                downloader = new Downloader ();

            return downloader;
        }

        private Downloader () {
            downloads = new GLib.HashTable <string,Download> (str_hash, str_equal);

            session = new Soup.SessionAsync ();
            session.add_feature_by_type (typeof (Soup.ProxyResolverDefault));

            var file = File.new_for_path(Environment.get_home_dir () + "/.cache/reddit-app/media/");
            if (!file.query_exists ()) {
                file.make_directory_with_parents();
            }
        }

        public async File download (string id, File remote_file,
                                    string cached_path) throws GLib.Error {

            bool failed = false;
            var cached_file = File.new_for_path (cached_path);
            if (cached_file.query_exists ()) {
                debug ("already available locally at '%s'. Not downloading.", cached_path);
                return cached_file;
            }

            var uri = remote_file.get_uri ();
            var download = downloads.get (id);
            if (download != null)
                // Already being downloaded
                return yield await_download (download, cached_path);

            debug ("Downloading '%s'...", uri);
            stdout.printf ("Downloading '%s'...", uri);
            download = new Download (id, uri, cached_file);
            downloads.set (id, download);

            try {
                if (remote_file.has_uri_scheme ("http") || remote_file.has_uri_scheme ("https"))
                    yield download_from_http (download);
                else
                    yield copy_file (remote_file, cached_file);
            } catch (GLib.Error error) {
                download_failed (download, error);
                failed = true;
            } finally {
                downloads.remove (id);
            }

            debug ("Downloaded '%s' and its now locally available at '%s'.", uri, cached_path);
            downloaded (download);

            return cached_file;
        }

        private async void download_from_http (Download download) throws GLib.Error {
            var msg = new Soup.Message ("GET", download.uri);
            var address = msg.get_address ();
            var connectable = new NetworkAddress (address.name, (uint16) address.port);
            var network_monitor = NetworkMonitor.get_default ();
            if (!(yield network_monitor.can_reach_async (connectable)))
                warning ("Failed to reach host '%s' on port '%d'", address.name, address.port);

            session.queue_message (msg, (session, msg) => {
                download_from_http.callback ();
            });
            yield;
            if (msg.status_code != Soup.KnownStatusCode.OK) {
                debug (msg.reason_phrase);
                stdout.printf("\ncould not download image\n" + msg.status_code.to_string());
            } else {
                try {
                    stdout.printf("\ncopying downloaded image to file\n");
                    yield download.cached_file.replace_contents_async (msg.response_body.data, null, false, 0, null, null);
                } catch (Error e) {
                    debug (e.message);
                }
            }
        }

        private async File? await_download (Download download,
                                            string cached_path) throws GLib.Error {
            File downloaded_file = null;
            GLib.Error download_error = null;

            File cached_file = File.new_for_path (cached_path);

            SourceFunc callback = await_download.callback;
            var downloaded_id = downloaded.connect ((downloader, downloaded) => {
                if (downloaded.uri != download.uri)
                    return;

                downloaded_file = downloaded.cached_file;
                callback ();
            });
            var downloaded_failed_id = download_failed.connect ((downloader, failed_download, error) => {
                if (failed_download.uri != download.uri)
                    return;

                download_error = error;
                callback ();
            });

            debug ("'%s' already being downloaded. Waiting for download to complete..", download.uri);
            yield; // Wait for it
            debug ("Finished waiting for '%s' to download.", download.uri);
            disconnect (downloaded_id);
            disconnect (downloaded_failed_id);

            if (download_error != null) {
                throw download_error;
            } else {
                if (downloaded_file.get_path () != cached_path)
                    yield downloaded_file.copy_async (cached_file, FileCopyFlags.NONE);
                else
                    cached_file = downloaded_file;
            }

            return cached_file;
        }

        public async void copy_file (File src_file, File dest_file, Cancellable? cancellable = null) throws GLib.Error {
            try {
                debug ("Copying '%s' to '%s'..", src_file.get_path (), dest_file.get_path ());
                yield src_file.copy_async (dest_file, 0, Priority.DEFAULT, cancellable);
                debug ("Copied '%s' to '%s'.", src_file.get_path (), dest_file.get_path ());
            } catch (IOError.EXISTS error) {
                stdout.printf("ioerror in Downloader.copy_file");
            }
        }
    }
}
