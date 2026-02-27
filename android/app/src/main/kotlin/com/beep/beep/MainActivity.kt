/**
 * MainActivity - Flutter 主 Activity
 * 
 * 设计原理：
 * 作为 Flutter 与 Android 原生代码的桥梁，
 * 通过 MethodChannel 实现双向通信。
 * 
 * 功能：
 * 1. 启动/停止前台服务
 * 2. 请求电池优化白名单
 * 3. 打开系统自启动设置
 */
package com.beep.beep

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    companion object {
        private const val CHANNEL = "com.beep.beep/background"
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    startChimeService()
                    result.success(true)
                }
                "stopForegroundService" -> {
                    stopChimeService()
                    result.success(true)
                }
                "requestBatteryOptimization" -> {
                    val success = requestBatteryOptimization()
                    result.success(success)
                }
                "isBatteryOptimizationIgnored" -> {
                    val ignored = isBatteryOptimizationIgnored()
                    result.success(ignored)
                }
                "openAutoStartSettings" -> {
                    openAutoStartSettings()
                    result.success(true)
                }
                "getManufacturer" -> {
                    result.success(Build.MANUFACTURER)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    /**
     * 启动前台服务
     */
    private fun startChimeService() {
        val serviceIntent = Intent(this, ChimeService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
    
    /**
     * 停止前台服务
     */
    private fun stopChimeService() {
        val serviceIntent = Intent(this, ChimeService::class.java)
        stopService(serviceIntent)
    }
    
    /**
     * 请求忽略电池优化
     */
    private fun requestBatteryOptimization(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
                    startActivity(intent)
                    return true
                } catch (e: Exception) {
                    e.printStackTrace()
                    return false
                }
            }
            return true // 已经在白名单中
        }
        return true // Android 6.0 以下不需要
    }
    
    /**
     * 检查是否已忽略电池优化
     */
    private fun isBatteryOptimizationIgnored(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true
    }
    
    /**
     * 打开自启动设置页面（国产 ROM）
     * 
     * 不同厂商的自启动管理页面路径不同，
     * 这里尝试常见的几种。
     */
    private fun openAutoStartSettings() {
        val manufacturer = Build.MANUFACTURER.lowercase()
        
        val intent = when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") -> {
                Intent().apply {
                    component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                }
            }
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> {
                Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                }
            }
            manufacturer.contains("oppo") || manufacturer.contains("realme") -> {
                Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                }
            }
            manufacturer.contains("vivo") || manufacturer.contains("iqoo") -> {
                Intent().apply {
                    component = ComponentName(
                        "com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"
                    )
                }
            }
            manufacturer.contains("oneplus") -> {
                Intent().apply {
                    component = ComponentName(
                        "com.oneplus.security",
                        "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
                    )
                }
            }
            else -> {
                // 通用：打开应用详情页
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
            }
        }
        
        try {
            startActivity(intent)
        } catch (e: Exception) {
            // 如果特定页面打不开，打开应用详情页
            val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(fallbackIntent)
        }
    }
}

