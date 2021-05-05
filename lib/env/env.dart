import 'package:envify/envify.dart';

part 'env.g.dart';

/*
1. Create the app here: https://old.reddit.com/prefs/apps

CLIENT_ID=
REDIRECT_URI=
CUSTOM_URI_SCHEME=

2. Copy the above values to a .env file at the root of the project

/flutter_reddit
  /lib
  /test
  .env <--
  pubspec.yaml

Run `flutter run build_runner build`

*/
@Envify()
abstract class Env {
  static const String client_id = _Env.client_id;
  static const String redirect_uri = _Env.redirect_uri;
  static const String custom_uri_scheme = _Env.custom_uri_scheme;
}
