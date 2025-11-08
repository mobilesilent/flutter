package com.example.automaticmb

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.automaticmb/dnd"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val ctx = applicationContext
                val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (call.method) {

                    "openDndSettings" -> {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success("opened")
                    }

                    "startDnd" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && nm.isNotificationPolicyAccessGranted) {
                            nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                            result.success("started")
                        } else {
                            result.error("NO_PERMISSION", "Notification policy access not granted", null)
                        }
                    }

                    "cancelDnd" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && nm.isNotificationPolicyAccessGranted) {
                            nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                            result.success("cancelled")
                        } else {
                            result.error("NO_PERMISSION", "Notification policy access not granted", null)
                        }
                    }

                    "scheduleDndStartAt" -> {
                        val startMillis = call.argument<Long>("startMillis") ?: 0L
                        scheduleDndAction(ctx, startMillis, DndReceiver.ACTION_START)
                        result.success("scheduled_start")
                    }

                    "scheduleDndEndAt" -> {
                        val endMillis = call.argument<Long>("endMillis") ?: 0L
                        scheduleDndAction(ctx, endMillis, DndReceiver.ACTION_STOP)
                        result.success("scheduled_end")
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleDndAction(context: Context, triggerAtMillis: Long, action: String) {
        val intent = Intent(context, DndReceiver::class.java).apply {
            this.action = action
        }

        val requestCode = (action.hashCode() xor (triggerAtMillis and 0xffffffff).toInt())

        val pending = PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pending)
        }
    }
}
