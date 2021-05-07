/// Returns the path to the Reddit api endpoints
///
/// Extend this class with any of your own endpoints
///
/// Possible endpoints are found here:
/// https://www.reddit.com/dev/api
class Endpoints {
  /// reddit.com/api/v1/me
  ///
  static String get me => '/api/v1/me';

  /// reddit.com/r/[subreddit]/about
  static String aboutSubreddit(String sub) => '/r/$sub/about';
}
