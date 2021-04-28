import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify()
abstract class Env {
  static const String client_id = _Env.client_id;
  static const String redirect_uri = _Env.redirect_uri;
  static const String custom_uri_scheme = _Env.custom_uri_scheme;
}
