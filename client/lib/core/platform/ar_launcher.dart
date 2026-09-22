import 'package:flutter/services.dart';

class ArLauncher {
  ArLauncher._();

  static const MethodChannel _channel = MethodChannel('roomfit/ar_launcher');

  static Future<void> launch(Uri uri) async {
    await _channel.invokeMethod<bool>('launch', {'url': uri.toString()});
  }
}
