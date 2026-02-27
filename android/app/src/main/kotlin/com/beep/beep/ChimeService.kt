/**
 * ChimeService - 前台服务（后台保活核心）
 * 
 * 设计原理：
 * Android 8.0+ 对后台服务有严格限制，普通后台服务容易被系统杀死。
 * 前台服务通过显示一个常驻通知，告知用户应用正在运行，
 * 系统会给予更高的进程优先级，大幅降低被杀概率。
 * 
 * 为什么使用前台服务：
 * 1. 最高优先级的后台存活方式
 * 2. 符合 Android 设计规范（用户知情）
 * 3. 支持精确定时任务
 * 
 * 缺点：
 * 1. 状态栏会显示常驻通知
 * 2. 用户可能觉得烦人而关闭
 */
package com.beep.beep

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class ChimeService : Service() {
    
    companion object {
        private const val TAG = "BeepChimeService"
        private const val CHANNEL_ID = "beep_foreground_channel"
        private const val NOTIFICATION_ID = 1001
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "ChimeService created")
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "ChimeService started")
        
        // 启动前台服务
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        
        // 返回 START_STICKY 表示服务被杀后系统会尝试重启
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "ChimeService destroyed")
        
        // 服务被销毁时尝试重启（部分 ROM 有效）
        val restartIntent = Intent(applicationContext, ChimeService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.startForegroundService(restartIntent)
        } else {
            applicationContext.startService(restartIntent)
        }
    }
    
    /**
     * 创建通知渠道（Android 8.0+ 必需）
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Beep Service",
                NotificationManager.IMPORTANCE_LOW  // 低重要性，不会发出声音
            ).apply {
                description = "Keeps Beep running for hourly chimes"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    /**
     * 创建前台服务通知
     */
    private fun createNotification(): Notification {
        // 点击通知打开应用
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Beep")
            .setContentText("Hourly chime is active")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setOngoing(true)  // 不可滑动删除
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
}
