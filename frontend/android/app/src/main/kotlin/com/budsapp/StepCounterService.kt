package com.budsapp

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class StepCounterService : Service(), SensorEventListener {
    companion object {
        private const val TAG = "StepCounterService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "step_counter_channel"
        
        // MethodChannel 메서드 이름 상수
        const val METHOD_CHANNEL_NAME = "com.budsapp/stepcounter"
        const val EVENT_CHANNEL_NAME = "com.budsapp/stepcounter_events"
        
        // SharedPreferences 키 값
        private const val PREFS_NAME = "StepCounterPrefs"
        private const val KEY_INITIAL_STEP_COUNT = "initial_step_count"
        private const val KEY_LAST_BOOT_COUNT = "last_boot_count"
        private const val KEY_SAVED_DAY = "saved_day"
        private const val KEY_DAILY_STEPS = "daily_steps"
        
        // EventChannel 이벤트 싱크 (이벤트 발송자)
        var eventSink: EventChannel.EventSink? = null
    }
    
    private lateinit var sensorManager: SensorManager
    private var stepCounterSensor: Sensor? = null
    private var initialStepCount: Float = 0f
    private var currentSteps: Int = 0
    private var sharedPreferences: SharedPreferences? = null
    private var isFirstRun = true
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        
        // SharedPreferences 초기화
        sharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        // 센서 매니저 초기화
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepCounterSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        
        // 걸음 수 센서가 없는 경우 처리
        if (stepCounterSensor == null) {
            Log.e(TAG, "No step counter sensor found on this device")
            stopSelf()
            return
        }
        
        // 날짜가 변경되었는지 확인하고 처리
        checkDateChanged()
        
        // 알림 채널 생성 (Android 8.0 이상)
        createNotificationChannel()
        
        // 포그라운드 서비스 시작
        startForeground(NOTIFICATION_ID, createNotification(0))
        
        // 센서 리스너 등록
        sensorManager.registerListener(
            this,
            stepCounterSensor,
            SensorManager.SENSOR_DELAY_NORMAL
        )
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")
        return START_STICKY
    }
    
    override fun onBind(p0: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        Log.d(TAG, "Service destroyed")
        // 센서 리스너 해제
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }
    
    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            val totalSteps = event.values[0]
            
            // 첫 실행 시 초기값 저장
            if (isFirstRun) {
                // 저장된 초기값이 있는지 확인
                val savedInitialSteps = sharedPreferences?.getFloat(KEY_INITIAL_STEP_COUNT, -1f)
                
                if (savedInitialSteps == -1f) {
                    // 처음 실행되는 경우
                    initialStepCount = totalSteps
                    sharedPreferences?.edit()?.putFloat(KEY_INITIAL_STEP_COUNT, initialStepCount)?.apply()
                } else {
                    // 이미 실행된 적이 있는 경우
                    initialStepCount = savedInitialSteps ?: totalSteps
                }
                
                isFirstRun = false
            }
            
            // 오늘의 걸음 수 계산
            val newSteps = (totalSteps - initialStepCount).toInt()
            
            // 음수나 비정상적인 값 필터링
            if (newSteps < 0) {
                Log.d(TAG, "음수 걸음 수 값이 감지됨, 무시합니다: $newSteps")
                return
            }
            
            // 이전 값과 같으면 업데이트 하지 않음
            if (currentSteps == newSteps) {
                return
            }
            
            currentSteps = newSteps
            
            // 로그로 확인
            Log.d(TAG, "Initial steps: $initialStepCount, Current steps: $currentSteps, Total: $totalSteps")
            
            // 알림 업데이트
            updateNotification(currentSteps)
            
            // 걸음 수 저장
            saveSteps(currentSteps)
            
            // 이벤트 전송 (Flutter로)
            eventSink?.success(currentSteps)
        }
    }
    
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // 정확도 변경 시 처리 (필요하면 구현)
    }
    
    // 알림 채널 생성 (Android 8.0 이상)
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "걸음 수 측정"
            val descriptionText = "앱이 꺼져도 걸음 수를 측정합니다"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    // 알림 생성
    private fun createNotification(steps: Int): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("걸음 수 측정 중")
            .setContentText("오늘 걸음 수: $steps 걸음")
            .setSmallIcon(R.mipmap.island)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
    
    // 알림 업데이트
    private fun updateNotification(steps: Int) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, createNotification(steps))
    }
    
    // 날짜가 변경되었는지 확인하고 처리
    private fun checkDateChanged() {
        val dateFormat = SimpleDateFormat("yyyyMMdd", Locale.getDefault())
        val currentDate = dateFormat.format(Date())
        
        val savedDate = sharedPreferences?.getString(KEY_SAVED_DAY, "") ?: ""
        
        if (savedDate != currentDate) {
            // 날짜가 변경된 경우 초기값 리셋
            sharedPreferences?.edit()?.apply {
                putString(KEY_SAVED_DAY, currentDate)
                // 이전 걸음 수 저장 (필요시)
                val previousSteps = sharedPreferences?.getInt(KEY_DAILY_STEPS, 0) ?: 0
                Log.d(TAG, "Date changed. Previous day steps: $previousSteps")
                
                // 새 날짜의 걸음 수 초기화
                putInt(KEY_DAILY_STEPS, 0)
                
                // 초기값 재설정 (부팅 후 누적값을 현재 초기값으로)
                if (stepCounterSensor != null) {
                    isFirstRun = true  // 다시 초기값을 설정하도록 플래그 설정
                }
            }?.apply()
        }
    }
    
    // 걸음 수 저장
    private fun saveSteps(steps: Int) {
        sharedPreferences?.edit()?.putInt(KEY_DAILY_STEPS, steps)?.apply()
    }
    
    // 걸음 수 가져오기 (플러터에서 호출할 메서드)
    fun getSteps(): Int {
        return currentSteps
    }
} 