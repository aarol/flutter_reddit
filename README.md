# flutter_reddit

Simple Flutter library for interacting with Reddit. Supports App-Only OAuth, uses [oauth2_client](https://pub.dev/packages/oauth2_client).

This library handles authorization, parsing of major reddit pages.

## Documentation 

Bla Vla use use do do somenthing smthng

## Prerequisites 

### Registering the application

Before you can start using the package, you must register your application [here](https://www.reddit.com/prefs/apps).

### OAuth2_client stuff

/* Copied from the oauth2_client documentation */

If at all possible, when registering your application ,try **not** to use HTTPS as the scheme part of the redirect uri, because in that case your application won't intercept the server redirection, as it will be automatically handled by the system browser (at least on Android). Just use a custom scheme, such as "my.test.app" or any other scheme you want.

If the OAuth2 server allows only HTTPS uri schemes and you are developing an Android app, refer to the FAQ section.

### Android 
If Android is one of your targets, you must first set the `minSdkVersion` in the build.gradle file:
```
defaultConfig {
  ...
   minSdkVersion 18
   ...
```

Again on Android, if your application uses the Authorization Code flow, you first need to modify the AndroidManifest.xml file adding the intent filter needed to open the browser window for the authorization workflow. The library relies on the flutter_web_auth package to allow the Authorization Code flow.

 `AndroidManifest.xml`


```xml
 <activity android:name="com.linusu.flutter_web_auth.CallbackActivity" >
 	<intent-filter android:label="flutter_web_auth">
		<action android:name="android.intent.action.VIEW" />
		<category android:name="android.intent.category.DEFAULT" />
		<category android:name="android.intent.category.BROWSABLE" />
		<data android:scheme="my.test.app" />
	</intent-filter>
 </activity>
```


### iOS 
On iOS you need to set the platform in the `ios/Podfile` file:

```
platform :ios, '11.0'
```


## Installation
Will be added when you can actually install it.


## Usage

### App-Only OAuth
Application only OAuth kaise hota humko nahi malum aarol se puch ke bateyenge

### Oauth with credentials
Ye bhi nai maluym puch ke bateynge
