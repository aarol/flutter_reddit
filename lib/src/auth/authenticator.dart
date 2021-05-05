import 'package:flutter/foundation.dart';
import 'package:flutter_reddit/src/oauth_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

class Authenticator {
  String? _anonymousToken;

  set anonymousToken(String val) => _anonymousToken = val;

  final OAuth2Helper _helper;
  final RedditOAuthClient _client;
  final String clientId;

  bool get isAnonymous => _anonymousToken != null;

  Authenticator(this._helper, this._client, this.clientId);

  Future<String> getToken() async {
    late final String token;

    // use anonymous token first
    if (_anonymousToken != null) {
      token = _anonymousToken!;
    } else {
      // if it doesnt exist, then check if token not in storage
      final _token = await _helper.getTokenFromStorage();
      if (_token == null || !_token.hasRefreshToken()) {
        // should get token from appOnly auth
        final res = await _client.getTokenWithAppOnlyFlow(
          clientId: clientId,
        );
        // set anonymous token for "caching"
        _anonymousToken = res.accessToken!;
        token = res.accessToken!;
      } else {
        // token is in storage and used
        final res = await _helper.getToken();

        token = res!.accessToken!;
        // set anonymous token to null just in case it wasn't before
        _anonymousToken = null;
      }
    }

    return token;
  }
}
