import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The one method channel. Every public call is a thin message to the native SDK: the plugin never
/// queues, retries or talks to ingest.
const MethodChannel tapllChannel = MethodChannel('com.tapll/tapll');

/// Invokes [method] and never throws: a broken or missing native side must not take the app down.
Future<T?> invokeTapll<T>(String method, [Map<String, Object?>? arguments]) async {
  try {
    return await tapllChannel.invokeMethod<T>(method, arguments);
  } on MissingPluginException catch (e) {
    tapllDebugLog('$method: native side not available ($e)');
  } on PlatformException catch (e) {
    tapllDebugLog('$method failed: ${e.code} ${e.message}');
  } catch (e) {
    tapllDebugLog('$method failed: $e');
  }
  return null;
}

/// Fire-and-forget form for calls that return nothing.
void sendTapll(String method, [Map<String, Object?>? arguments]) {
  // ignore: discarded_futures
  invokeTapll<void>(method, arguments);
}

/// Debug-only log; silent in release.
void tapllDebugLog(String message) {
  if (kDebugMode) debugPrint('[Tapll] $message');
}
