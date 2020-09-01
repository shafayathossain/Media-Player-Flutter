package com.shafayat.media_player

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.view.KeyEvent

class RemoteReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            if (Intent.ACTION_MEDIA_BUTTON == intent.action) {
                val event = intent.getParcelableExtra<KeyEvent>(Intent.EXTRA_KEY_EVENT)
                if (event != null && event.action == KeyEvent.ACTION_DOWN) {
                    when (event.keyCode) {
                        KeyEvent.KEYCODE_MEDIA_PAUSE -> AudioServiceBinder.service?.pauseAudio()
                        KeyEvent.KEYCODE_MEDIA_PLAY -> AudioServiceBinder.service?.startAudio(0)
                    }
                }
            }
        } catch (e: Exception) { /* ignore */
        }
    }
}