package com.example.automaticmb

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class DndReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_START = "com.example.automaticmb.ACTION_START_DND"
        const val ACTION_STOP = "com.example.automaticmb.ACTION_STOP_DND"
        private const val TAG = "DndReceiver"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return

        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            Log.w(TAG, "DND control requires Android M+")
            return
        }

        if (!nm.isNotificationPolicyAccessGranted) {
            Log.w(TAG, "DND permission not granted")
            return
        }

        when (intent.action) {
            ACTION_START -> {
                nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_NONE)
                Log.d(TAG, "DND ENABLED by receiver")
            }
            ACTION_STOP -> {
                nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                Log.d(TAG, "DND DISABLED by receiver")
            }
            else -> {
                Log.d(TAG, "Unknown action: ${intent.action}")
            }
        }
    }
}
