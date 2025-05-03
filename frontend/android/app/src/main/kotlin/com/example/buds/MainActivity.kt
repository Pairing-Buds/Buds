package com.example.buds

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.os.Bundle
import android.app.KeyguardManager
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest
import android.app.ActivityManager

class MainActivity : FlutterActivity() {
    private val BATTERY_CHANNEL = "com.buds.app/battery_optimization"
    private val NOTIFICATION_INTENT_CHANNEL = "com.buds.app/notification_intent"
    private val LOCK_SCREEN_CHANNEL = "com.buds.app/lock_screen_settings"
    
    // 걸음 수 서비스 관련 상수
    private val STEP_COUNTER_PERMISSION_REQUEST_CODE = 1001
    
    // 알람 인텐트 여부를 저장하는 변수
    private var wasFromAlarmIntent = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 알람 인텐트인 경우에만 화면 켜기 및 잠금화면 위에 표시
        wasFromAlarmIntent = isAlarmIntent(intent)
        if (wasFromAlarmIntent) {
            enableLockScreenBypass()
            println("MainActivity: 알람 인텐트로 감지되어 잠금화면 바이패스 활성화")
        } else {
            // 알람 인텐트가 아닌 경우 기본 동작으로 설정
            disableLockScreenBypass()
            println("MainActivity: 일반 인텐트로 감지되어 잠금화면 바이패스 비활성화")
        }
    }
    
    // 잠금화면 바이패스 활성화
    private fun enableLockScreenBypass() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // 잠금화면 해제 (API 레벨 26 이상)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }
    }
    
    // 잠금화면 바이패스 비활성화
    private fun disableLockScreenBypass() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
    }
    
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
        
        // 잠금화면 설정 관련 채널
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_SCREEN_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "disableLockScreenBypass") {
                // 알람 화면에서 벗어났을 때 호출되는 메서드
                disableLockScreenBypass()
                wasFromAlarmIntent = false
                println("MainActivity: 잠금화면 바이패스 비활성화 요청 처리됨")
                result.success(true)
            } else if (call.method == "enableLockScreenBypass") {
                // 알람 화면으로 다시 진입할 때 호출되는 메서드
                enableLockScreenBypass()
                wasFromAlarmIntent = true
                println("MainActivity: 잠금화면 바이패스 활성화 요청 처리됨")
                result.success(true)
            } else if (call.method == "getLockScreenBypassStatus") {
                // 현재 잠금화면 바이패스 상태 반환
                result.success(wasFromAlarmIntent)
            } else {
                result.notImplemented()
            }
        }
        
        // 걸음 수 측정 서비스 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, StepCounterService.METHOD_CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "startStepCounterService" -> {
                    // 걸음 수 측정 서비스 시작
                    if (checkAndRequestPermission()) {
                        startStepCounterService()
                        result.success(true)
                    } else {
                        result.success(false) // 권한이 없어 서비스를 시작할 수 없음
                    }
                }
                "stopStepCounterService" -> {
                    // 걸음 수 측정 서비스 중지
                    stopStepCounterService()
                    result.success(true)
                }
                "getStepCount" -> {
                    // 현재 걸음 수 가져오기
                    val prefs = getSharedPreferences(StepCounterService.Companion::class.java.declaringClass.name + ".PREFS_NAME", Context.MODE_PRIVATE)
                    val steps = prefs.getInt("daily_steps", 0)
                    result.success(steps)
                }
                "checkPermission" -> {
                    // 권한 확인
                    result.success(checkPermission())
                }
                "requestPermission" -> {
                    // 권한 요청
                    requestPermission()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    // 서비스 실행 상태 확인
                    result.success(isStepCounterServiceRunning())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 걸음 수 실시간 이벤트 채널 설정
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, StepCounterService.EVENT_CHANNEL_NAME).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    StepCounterService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    StepCounterService.eventSink = null
                }
            }
        )
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
        
        // 새 인텐트가 알람 인텐트인 경우 화면 켜기 및 잠금화면 위에 표시
        val isAlarm = isAlarmIntent(intent)
        if (isAlarm) {
            enableLockScreenBypass()
            wasFromAlarmIntent = true
            println("MainActivity.onNewIntent: 알람 인텐트 감지, 잠금화면 바이패스 활성화")
        }
    }
    
    // 앱이 일시정지될 때 호출 (화면이 꺼질 때 등)
    override fun onPause() {
        super.onPause()
        // 현재 상태 저장 (알람 인텐트로 시작되었는지)
        val prefs = getSharedPreferences("com.buds.app.PREFS", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("was_from_alarm_intent", wasFromAlarmIntent).apply()
        println("MainActivity.onPause: 알람 상태 저장 was_from_alarm_intent=$wasFromAlarmIntent")
    }
    
    // 앱이 재개될 때 호출 (화면이 다시 켜질 때 등)
    override fun onResume() {
        super.onResume()
        
        // 알람 인텐트로 시작되었었는지 확인
        val prefs = getSharedPreferences("com.buds.app.PREFS", Context.MODE_PRIVATE)
        val wasFromAlarm = prefs.getBoolean("was_from_alarm_intent", false)
        
        // 화면이 꺼졌다가 다시 켜졌을 때, 알람 인텐트로 시작된 것이 아니면 
        // 잠금화면 바이패스 비활성화 (정상적으로 잠금화면이 표시되도록)
        if (!wasFromAlarm) {
            disableLockScreenBypass()
            wasFromAlarmIntent = false
            println("MainActivity.onResume: 일반 상태로 복귀, 잠금화면 바이패스 비활성화")
        } else {
            println("MainActivity.onResume: 알람 인텐트로부터 복귀, 잠금화면 바이패스 상태 유지")
        }
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
    
    // 걸음 수 측정 서비스 시작
    private fun startStepCounterService() {
        val serviceIntent = Intent(this, StepCounterService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
    
    // 걸음 수 측정 서비스 중지
    private fun stopStepCounterService() {
        val serviceIntent = Intent(this, StepCounterService::class.java)
        stopService(serviceIntent)
    }
    
    // 권한 확인
    private fun checkPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACTIVITY_RECOGNITION
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    // 권한 요청
    private fun requestPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
            STEP_COUNTER_PERMISSION_REQUEST_CODE
        )
    }
    
    // 권한 확인 및 요청
    private fun checkAndRequestPermission(): Boolean {
        if (!checkPermission()) {
            requestPermission()
            return false
        }
        return true
    }
    
    // 권한 요청 결과 처리
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == STEP_COUNTER_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // 권한이 부여되면 서비스 시작
                startStepCounterService()
            }
        }
    }
    
    // 걸음 수 측정 서비스가 실행 중인지 확인
    private fun isStepCounterServiceRunning(): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (StepCounterService::class.java.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
