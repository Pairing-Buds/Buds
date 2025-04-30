package com.example.buds

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.buds.app/battery_optimization"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 메서드 채널 설정
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // 배터리 최적화 무시 요청
            if (call.method == "requestBatteryOptimizationDisable") {
                result.success(requestBatteryOptimizationDisable())
            } else {
                result.notImplemented()
            }
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
}
