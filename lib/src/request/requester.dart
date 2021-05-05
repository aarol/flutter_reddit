import 'package:dio/dio.dart';

enum RequestType {
  POST,
  GET,
}

class Requester {
  final Dio dio;

  Requester(this.dio);

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<Response> request(
      RequestType type, Uri url, dynamic data, Future<String> onRenew()) async {
    final send = () {
      dio.options.headers = {'Authorization': 'bearer $_token'};
      switch (type) {
        case RequestType.GET:
          return dio.getUri(url);
        case RequestType.POST:
          return dio.postUri(url, data: data);
        default:
          throw '';
      }
    };

    if (_token == null) {
      setToken(await onRenew());
    }
    try {
      return send();
    } catch (e) {
      if (e is DioError) {
        if (e.response!.statusCode == 401) {
          //try getting the token again
          //by calling the onRenew function
          setToken(await onRenew());
          return send();
        }
      }
      rethrow;
    }
  }
}
