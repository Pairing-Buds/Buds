package com.example.buds

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {
    // 알람 알림을 위한 PendingIntent 생성
    fun createAlarmNotificationIntent(context: Context, notificationId: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = "com.buds.app.ALARM_NOTIFICATION"
            putExtra("notification_id", notificationId)
            putExtra("is_alarm", true)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        
        return PendingIntent.getActivity(context, notificationId, intent, flags)
    }
} 