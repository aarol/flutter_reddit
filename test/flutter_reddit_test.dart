import 'package:dio/dio.dart';
import 'package:flutter_reddit/env/env.dart';
import 'package:flutter_reddit/flutter_reddit.dart';
import 'package:flutter_reddit/src/auth/authEvent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_reddit_test.mocks.dart';
import 'generated.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('authState', () {
    late MockTokenStorage tokenStorage;
    late MockStorage storage;
    late MockAccessTokenResponse tokenResponse;
    late MockRedditOAuthClient client;
    late MockDio dio;

    final tToken = 'tToken';
    final tDeviceId = 'tDeviceId';
    final tScopes = ['identity', 'vote', 'read'];

    setUp(() {
      tokenStorage = MockTokenStorage();
      storage = MockStorage();
      tokenResponse = MockAccessTokenResponse();
      client = MockRedditOAuthClient();
      dio = MockDio();
    });
    test('anonymous when no user present', () {
      // arrange
      when(tokenStorage.getToken(any)).thenAnswer((_) async => tokenResponse);
      when(tokenResponse.hasRefreshToken()).thenReturn(false);
      when(tokenStorage.storage).thenReturn(storage);
      when(storage.read(any)).thenAnswer((_) async => tDeviceId);
      when(tokenResponse.accessToken).thenReturn(tToken);
      when(client.getTokenWithAppOnlyFlow(clientId: anyNamed('clientId')))
          .thenAnswer((_) async => tokenResponse);
      when(dio.options).thenReturn(BaseOptions());
      // act
      final reddit = Reddit(
        clientId: Env.client_id,
        redirectUri: Env.redirect_uri,
        scopes: tScopes,
        customUriScheme: Env.custom_uri_scheme,
        tokenStorage: tokenStorage,
        oAuth2client: client,
        dioClient: dio,
      );

      // assert
      expectLater(
        reddit.authState,
        emitsInOrder(
          [
            AuthLoading(),
            AuthAnonymousLogin(),
          ],
        ),
      );
    });
  });
}
