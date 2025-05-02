package com.example.buds

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BATTERY_CHANNEL = "com.buds.app/battery_optimization"
    private val NOTIFICATION_INTENT_CHANNEL = "com.buds.app/notification_intent"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 배터리 최적화 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            // 배터리 최적화 무시 요청
            if (call.method == "requestBatteryOptimizationDisable") {
                result.success(requestBatteryOptimizationDisable())
            } else {
                result.notImplemented()
            }
        }
        
        // 알림 인텐트 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_INTENT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialIntent") {
                val isAlarm = isAlarmIntent(intent)
                val notificationId = intent?.getIntExtra("notification_id", -1) ?: -1
                val action = intent?.action ?: ""
                val categories = intent?.categories?.joinToString() ?: ""
                val extras = Bundle()
                intent?.extras?.let { it ->
                    extras.putAll(it)
                }
                
                val intentData = HashMap<String, Any>()
                intentData["is_alarm"] = isAlarm
                intentData["notification_id"] = notificationId
                intentData["action"] = action
                intentData["categories"] = categories
                // "SELECT_NOTIFICATION" 액션인 경우 알람으로 간주
                if (action == "SELECT_NOTIFICATION") {
                    intentData["is_alarm"] = true
                }
                
                // 로그 출력 강화
                println("MainActivity: getInitialIntent - isAlarm=$isAlarm, notificationId=$notificationId, action=$action, categories=$categories")
                
                // 추가 정보: extras 출력
                intent?.extras?.keySet()?.forEach { key ->
                    val value = intent.extras?.get(key)
                    println("MainActivity: intent extra - $key=$value")
                }
                
                result.success(intentData)
            } else if (call.method == "testAlarmIntent") {
                // 테스트용 알람 인텐트 생성
                try {
                    val testIntent = Intent(this, MainActivity::class.java)
                    testIntent.action = "com.buds.app.ALARM_NOTIFICATION"
                    testIntent.putExtra("notification_id", 888)
                    testIntent.putExtra("is_alarm", true)
                    testIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    
                    // 현재 액티비티 종료 후 새 인텐트로 시작
                    finish()
                    startActivity(testIntent)
                    
                    println("MainActivity: 테스트 알람 인텐트 생성 및 실행 완료")
                    result.success(true)
                } catch (e: Exception) {
                    println("MainActivity: 테스트 알람 인텐트 실행 실패 - ${e.message}")
                    result.error("ERROR", "테스트 알람 인텐트 실행 실패", e.toString())
                }
            } else {
                result.notImplemented()
            }
        }
    }
    
    // 인텐트가 알람 인텐트인지 확인
    private fun isAlarmIntent(intent: Intent?): Boolean {
        val action = intent?.action
        val isAlarm = intent?.getBooleanExtra("is_alarm", false) ?: false
        val isAlarmAction = action == "com.buds.app.ALARM_NOTIFICATION"
        // SELECT_NOTIFICATION 액션인 경우도 알람 인텐트로 판단 (알림을 통해 앱이 시작된 경우)
        val isFromNotification = action == "SELECT_NOTIFICATION" || action == "android.intent.action.MAIN" && intent.hasCategory("android.intent.category.LAUNCHER") && intent.getBooleanExtra("from_notification", false)
        
        println("MainActivity: intent action=$action, isAlarm=$isAlarm, isAlarmAction=$isAlarmAction, isFromNotification=$isFromNotification")
        
        // 알림 ID를 확인하여 알람 관련 알림인지 확인
        val notificationId = intent?.getIntExtra("notification_id", -1) ?: -1
        val isAlarmId = notificationId == 0 || notificationId == 1 || notificationId == 100
        
        return isAlarm || isAlarmAction || isFromNotification || isAlarmId
    }
    
    // 새 인텐트 처리
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    // 배터리 최적화 무시 요청 메서드
    private fun requestBatteryOptimizationDisable(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val packageName = packageName
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            
            // 이미 배터리 최적화에서 제외되어 있는지 확인
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    // 배터리 최적화 무시 요청 인텐트 생성
                    val intent = Intent()
                    intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                    intent.data = Uri.parse("package:$packageName")
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    return true
                } catch (e: Exception) {
                    e.printStackTrace()
                    return false
                }
            }
            return true
        }
        return false
    }
}
