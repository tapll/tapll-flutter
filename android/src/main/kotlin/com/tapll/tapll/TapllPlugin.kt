package com.tapll.tapll

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.tapll.Tapll
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Moves method-channel calls from Dart into the native Tapll SDK. No logic of its own: the wrapper
 * never queues, retries, owns sessions or talks to ingest.
 */
class TapllPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also { it.setMethodCallHandler(this) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
    }

    @SuppressLint("RestrictedApi")
    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        try {
            when (call.method) {
                "configure" -> {
                    val ctx = context
                    val name = Arguments.string(args, "wrapperName")
                    val version = Arguments.string(args, "wrapperVersion")
                    // setWrapper must come before configure: the device context is built once per client.
                    if (name != null && version != null) Tapll.Wrapper.setWrapper(name, version)
                    val key = Arguments.string(args, "writeKey")
                    val mode = Arguments.privacyMode(Arguments.string(args, "privacyMode"))
                    if (ctx != null && key != null && mode != null) {
                        Tapll.configure(ctx, key, mode, Arguments.options(args["options"]))
                    }
                    result.success(null)
                }
                "track" -> {
                    Arguments.string(args, "name")?.let {
                        Tapll.track(
                            it,
                            Arguments.properties(args["properties"]),
                            Arguments.string(args, "feature"),
                            Arguments.featureRole(Arguments.string(args, "role")),
                            Arguments.string(args, "screen"),
                        )
                    }
                    result.success(null)
                }
                "screen" -> {
                    Arguments.string(args, "name")?.let {
                        Tapll.screen(it, Arguments.properties(args["properties"]), Arguments.string(args, "feature"))
                    }
                    result.success(null)
                }
                "identify" -> {
                    Arguments.string(args, "userId")?.let { Tapll.identify(it, Arguments.traits(args["traits"])) }
                    result.success(null)
                }
                "reset" -> { Tapll.reset(); result.success(null) }
                "setAnalyticsCollectionEnabled" -> {
                    Arguments.bool(args, "enabled")?.let { Tapll.setAnalyticsCollectionEnabled(it) }
                    result.success(null)
                }
                "optOut" -> { Tapll.optOut(); result.success(null) }
                "optIn" -> { Tapll.optIn(); result.success(null) }
                "handleDeepLink" -> {
                    Arguments.string(args, "url")?.let { Tapll.handleDeepLink(Uri.parse(it)) }
                    result.success(null)
                }
                "recordError" -> {
                    Arguments.string(args, "type")?.let { Tapll.recordError(it, Arguments.string(args, "reason")) }
                    result.success(null)
                }
                "setCrashKey" -> {
                    Arguments.string(args, "key")?.let { Tapll.setCrashKey(it, Arguments.string(args, "value")) }
                    result.success(null)
                }
                "leaveBreadcrumb" -> {
                    Arguments.string(args, "name")?.let { Tapll.leaveBreadcrumb(it) }
                    result.success(null)
                }
                "recordManagedError" -> {
                    Arguments.string(args, "type")?.let {
                        Tapll.Wrapper.recordManagedError(
                            it,
                            Arguments.string(args, "reason"),
                            Arguments.frames(args["frames"]),
                            Arguments.bool(args, "fatal") ?: false,
                            Arguments.string(args, "thread") ?: "main",
                        )
                    }
                    result.success(null)
                }
                "flush" -> Tapll.flush { main.post { result.success(null) } }
                "getInstallId" -> result.success(Tapll.installId)
                else -> result.notImplemented()
            }
        } catch (t: Throwable) {
            // The wrapper never takes the host down; the Dart side logs and moves on.
            result.error("tapll_error", t.message, null)
        }
    }

    companion object {
        const val CHANNEL = "com.tapll/tapll"
    }
}
