/**
 * BootReceiver - 开机自启动广播接收器
 * 
 * 设计原理：
 * Android 系统在开机完成后会发送 BOOT_COMPLETED 广播。
 * 应用通过注册此广播接收器，可以在开机后自动启动服务。
 * 
 * 注意事项：
 * 1. 需要 RECEIVE_BOOT_COMPLETED 权限
 * 2. 用户首次安装后需要手动打开一次应用才能生效
 * 3. 部分国产 ROM 需要用户手动授权自启动
 */
package com.beep.beep

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BeepBootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            Log.d(TAG, "Boot completed, starting ChimeService...")
            
            // 启动前台服务
            val serviceIntent = Intent(context, ChimeService::class.java)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Android 8.0+ 需要启动前台服务
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }
    }
}
