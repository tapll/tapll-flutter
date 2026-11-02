import Flutter
#if canImport(TapllCore)
import TapllCore
#endif

/// Moves method-channel calls from Dart into the native Tapll SDK (`TapllBridge`). No logic of its
/// own: the wrapper never queues, retries, owns sessions or talks to ingest.
public final class TapllPlugin: NSObject, FlutterPlugin {
    private let bridge = TapllBridge()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.tapll/tapll", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(TapllPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        bridge.handle(method: call.method, arguments: call.arguments) { outcome in
            // Replies go back on the platform thread; `flush` completes on a background one.
            DispatchQueue.main.async {
                switch outcome {
                case .success(let value): result(value)
                case .notImplemented: result(FlutterMethodNotImplemented)
                }
            }
        }
    }
}
