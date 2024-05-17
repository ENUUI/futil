package com.example.futil_android

import android.content.Context
import android.content.SharedPreferences
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.UUID

/** FutilAndroidPlugin */
class FutilAndroidPlugin : FlutterPlugin, FutilAndroidApi {
    private lateinit var context: Context
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        pluginBinding = null
        FutilAndroidApi.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        pluginBinding = binding
        FutilAndroidApi.setUp(binding.binaryMessenger, this)
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

    override fun sdkInt(callback: (Result<Long>) -> Unit) {
        callback(Result.success(android.os.Build.VERSION.SDK_INT.toLong()))
    }

    override fun isHarmonyOs(callback: (Result<Boolean>) -> Unit) {
        callback(Result.success(isHarmonyOS()))
    }

    override fun osVersion(callback: (Result<Map<String, String>?>) -> Unit) {
        callback(Result.success(getOsVersion()))
    }

    override fun deviceId(callback: (Result<String>) -> Unit) {
        callback(Result.success(getDeviceId()))
    }


}
