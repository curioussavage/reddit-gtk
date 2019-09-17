namespace RedditApp {
    namespace Utils {
		public string get_timestamp(int64 time) {
		    var post_time = new DateTime.from_unix_utc(time);
		    stdout.printf(post_time.to_string());
		    var now = new DateTime.now_utc();
		    var diff = now.difference(post_time); // microseconds since date
		    stdout.printf("\n\n microseconds for post diff " + diff.to_string() + " \n");
		    var timestamp_min = diff / 1000000 / 60;
		    if (timestamp_min < 1){
		       return "now";
		    }
		    if (timestamp_min < 60) {
		        return timestamp_min.to_string() + " m";
		    }
		    var timestamp_hour = timestamp_min / 60;
		    if (timestamp_hour < 24) {
		        return timestamp_hour.to_string() + " h";
		    }
		    var timestamp_day = timestamp_hour / 24;
		    if (timestamp_day < 365) {
		        return timestamp_day.to_string() + " d";
		    }
		    var timestamp_year = timestamp_day / 365;
		    return timestamp_year.to_string() + " y";
		}
    }
}