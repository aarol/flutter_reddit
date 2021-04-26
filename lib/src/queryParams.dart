class QueryParams {
  static MapEntry<String, dynamic> limit(int limit) => MapEntry('limit', limit);

  static MapEntry<String, dynamic> after(String fullname) =>
      MapEntry('after', after);

  static MapEntry<String, dynamic> before(String fullname) =>
      MapEntry('before', before);

  static MapEntry<String, dynamic> depth(int depth) => MapEntry('depth', depth);
}
