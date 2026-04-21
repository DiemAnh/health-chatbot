import 'dart:io' show Platform;

String getApiHostPlatform() {
  if (Platform.isAndroid) {
    return 'http://160.30.136.196:3465';
  }
  return 'http://160.30.136.196:3465';
}
