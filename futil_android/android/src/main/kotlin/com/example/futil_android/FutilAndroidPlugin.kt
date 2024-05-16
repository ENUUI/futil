package com.example.futil_android

import android.content.Context
import android.content.SharedPreferences

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID

/** FutilAndroidPlugin */
class FutilAndroidPlugin : FlutterPlugin, MethodCallHandler {
    
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "github.enuui/futil")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "os_version" -> result.success(getOsVersion())
            "device_id" -> result.success(getDeviceId())
            "skd_int" -> result.success(android.os.Build.VERSION.SDK_INT)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getOsVersion(): Map<String, String> {
        val os = if (isHarmonyOS()) "HarmonyOS" else "Android"
        return mapOf("version" to android.os.Build.VERSION.RELEASE, "os" to os)
    }

    private fun getDeviceId(): String {
        val deviceId: String
        val key = "device_id"
        val sp: SharedPreferences =
            context.getSharedPreferences("settings_futil", Context.MODE_PRIVATE)
        val cacheId: String? = sp.getString(key, "")
        if (cacheId.isNullOrEmpty()) {
            deviceId = UUID.randomUUID().toString()
            sp.edit().putString(key, deviceId).apply()
        } else {
            deviceId = cacheId
        }
        return deviceId
    }

    private fun isHarmonyOS(): Boolean {
        val harmonyOS = "harmony"
        return try {
            val clz = Class.forName("com.huawei.system.BuildEx")
            val method = clz.getMethod("getOsBrand")
            harmonyOS == method.invoke(clz)
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
