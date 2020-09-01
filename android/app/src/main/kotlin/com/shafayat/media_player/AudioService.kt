package com.shafayat.media_player

import android.app.Service
import android.content.Intent
import android.os.IBinder

class AudioService : Service() {
    private val audioServiceBinder = AudioServiceBinder()

    override fun onBind(intent: Intent): IBinder {
        return audioServiceBinder
    }

    override fun onDestroy() {
        audioServiceBinder.onDestroy()
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent) {
        audioServiceBinder.onDestroy()
        super.onTaskRemoved(rootIntent)
    }

    override fun onUnbind(intent: Intent): Boolean {
        audioServiceBinder.onDestroy()
        return super.onUnbind(intent)
    }
}