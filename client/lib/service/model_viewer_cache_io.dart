import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> clearModelViewerCache() async {
  try {
    final cacheDir = await getTemporaryDirectory();
    final webViewCache = Directory('${cacheDir.path}/WebView');
    if (await webViewCache.exists()) {
      await webViewCache.delete(recursive: true);
    }
  } catch (_) {}
}
