import 'package:flutter_reddit/env/env.dart';
import 'package:flutter_reddit/flutter_reddit.dart';
import 'package:flutter_reddit/src/auth/oauth_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oauth2_client/oauth2_helper.dart';

import '../generated.mocks.dart';

void main() {
  late MockTokenStorage mockTokenStorage;
  late MockStorage mockStorage;
  late OAuth2Helper helper;
  late RedditOAuthClient client;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    mockStorage = MockStorage();

    client = RedditOAuthClient(
        redirectUri: Env.redirect_uri,
        customUriScheme: Env.custom_uri_scheme,
        storage: mockTokenStorage);
    helper = OAuth2Helper(
      client,
      clientId: Env.client_id,
      tokenStorage: mockTokenStorage,
    );
  });
  group('anonymous login', () {
    final tScopes = ['identity', 'vote', 'read'];

    test(
      'should complete',
      () async {
        // arrange
        when(mockTokenStorage.getToken(any)).thenAnswer((_) async => null);
        when(mockTokenStorage.storage).thenReturn(mockStorage);
        when(mockStorage.read('deviceId')).thenAnswer((_) async => null);
        when(mockStorage.write(any, any)).thenAnswer((_) async => null);
        // act
        final reddit = Reddit(
          clientId: Env.client_id,
          redirectUri: Env.redirect_uri,
          scopes: tScopes,
          customUriScheme: Env.custom_uri_scheme,
          oAuth2Helper: helper,
          oAuth2client: client,
          tokenStorage: mockTokenStorage,
        );
        final response = await reddit.get(Endpoints.me);
        // assert
        verify(mockTokenStorage.getToken(any));
        expect(response.data, allOf(isMap, isNotEmpty));
      },
    );
  });
}
