package com.shafayat.media_player

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

class MediaNotificationManagerService : Service() {
    /**
     * The binder used by clients to access this instance.
     */
    private val mBinder: Binder = MediaNotificationManagerServiceBinder()

    /**
     * The player managed by this service.
     */
    private var flutterPlayer: FlutterPlayer? = null

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onBind(intent: Intent): IBinder? {
        return mBinder
    }

    override fun onDestroy() {
        try {
            flutterPlayer?.onDestroy()
        } catch (e: Exception) { /* ignore */
        }
    }

    override fun onUnbind(intent: Intent): Boolean {
        try {
            flutterPlayer?.onDestroy()
            stopSelf()
        } catch (e: Exception) { /* ignore */
        }
        return false
    }

    override fun onTaskRemoved(rootIntent: Intent) {
        super.onTaskRemoved(rootIntent)
        flutterPlayer?.onDestroy()
        stopSelf()
    }

    /**
     * Used to set a player to control the MediaSession for.
     * @param player the player that should be controlled by this service.
     */
    fun setActivePlayer(player: FlutterPlayer?) {
        if (flutterPlayer != null) {
            flutterPlayer?.onDestroy()
        }
        flutterPlayer = player
    }

    /**
     * Clients access this service through this class.
     * Because we know this service always runs in the same process
     * as its clients, we don't need to deal with IPC.
     */
    inner class MediaNotificationManagerServiceBinder : Binder() {
        val service: MediaNotificationManagerService
            get() = this@MediaNotificationManagerService
    }
}