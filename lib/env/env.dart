import 'package:envify/envify.dart';

part 'env.g.dart';

/*
1. Create the app here: https://old.reddit.com/prefs/apps

CLIENT_ID, REDIRECT_URI and CUSTOM_URI_SCHEME are for an installed application

CONFIDENTIAL_SECRET, CONFIDENTIAL_ID are for a script application

CUSTOM_URI_SCHEME is the part before ://
(example://app/) --> example

CLIENT_ID=
REDIRECT_URI=
CUSTOM_URI_SCHEME=
CONFIDENTIAL_SECRET=
CONFIDENTIAL_ID=

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
  static const String confidential_id = _Env.confidential_id;
  static const String confidential_secret = _Env.confidential_secret;
}
