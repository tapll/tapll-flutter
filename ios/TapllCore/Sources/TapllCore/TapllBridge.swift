import Foundation
@_spi(Wrapper) import Tapll

public enum TapllBridgeResult {
    case success(Any?)
    case notImplemented
}

/// Forwards one method-channel call to the native Tapll SDK. Wrapper rule: nothing here queues,
/// retries, owns a session or talks to ingest; every call is the native SDK's.
public final class TapllBridge {
    public init() {}

    /// Handles `method`. `completion` is called exactly once, possibly on a background thread.
    public func handle(method: String, arguments: Any?, completion: @escaping (TapllBridgeResult) -> Void) {
        let args = arguments as? [String: Any] ?? [:]
        switch method {
        case "configure":
            // setWrapper must come before configure: the device context is built once per client.
            if let name = Arguments.string(args, "wrapperName"), let version = Arguments.string(args, "wrapperVersion") {
                Tapll.setWrapper(name: name, version: version)
            }
            if let key = Arguments.string(args, "writeKey"), let mode = Arguments.privacyMode(Arguments.string(args, "privacyMode")) {
                Tapll.configure(writeKey: key, privacyMode: mode, options: Arguments.options(args["options"]))
            }
            completion(.success(nil))

        case "track":
            if let name = Arguments.string(args, "name") {
                Tapll.track(
                    name,
                    properties: Arguments.properties(args["properties"]),
                    feature: Arguments.string(args, "feature"),
                    role: Arguments.featureRole(Arguments.string(args, "role")),
                    screen: Arguments.string(args, "screen")
                )
            }
            completion(.success(nil))

        case "screen":
            if let name = Arguments.string(args, "name") {
                Tapll.screen(name, properties: Arguments.properties(args["properties"]), feature: Arguments.string(args, "feature"))
            }
            completion(.success(nil))

        case "identify":
            if let id = Arguments.string(args, "userId") {
                Tapll.identify(userId: id, traits: Arguments.traits(args["traits"]))
            }
            completion(.success(nil))

        case "reset":
            Tapll.reset()
            completion(.success(nil))

        case "setAnalyticsCollectionEnabled":
            if let enabled = Arguments.bool(args, "enabled") { Tapll.setAnalyticsCollectionEnabled(enabled) }
            completion(.success(nil))

        case "optOut":
            Tapll.optOut()
            completion(.success(nil))

        case "optIn":
            Tapll.optIn()
            completion(.success(nil))

        case "handleDeepLink":
            if let url = Arguments.url(args) { Tapll.handleDeepLink(url) }
            completion(.success(nil))

        case "recordError":
            if let type = Arguments.string(args, "type") {
                Tapll.recordError(type, reason: Arguments.string(args, "reason"))
            }
            completion(.success(nil))

        case "setCrashKey":
            if let key = Arguments.string(args, "key") { Tapll.setCrashKey(key, Arguments.string(args, "value")) }
            completion(.success(nil))

        case "leaveBreadcrumb":
            if let name = Arguments.string(args, "name") { Tapll.leaveBreadcrumb(name) }
            completion(.success(nil))

        case "recordManagedError":
            if let type = Arguments.string(args, "type") {
                Tapll.recordManagedError(
                    type: type,
                    reason: Arguments.string(args, "reason"),
                    frames: Arguments.frames(args["frames"]),
                    fatal: Arguments.bool(args, "fatal") ?? false,
                    thread: Arguments.string(args, "thread") ?? "main"
                )
            }
            completion(.success(nil))

        case "flush":
            Task {
                await Tapll.flush()
                completion(.success(nil))
            }

        case "getInstallId":
            completion(.success(Tapll.installId))

        default:
            completion(.notImplemented)
        }
    }
}
