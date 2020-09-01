package com.shafayat.media_player

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.support.v4.media.session.MediaSessionCompat
import android.view.KeyEvent
import androidx.core.app.NotificationCompat

object PlayerNotificationUtil {
    /**
     * Creates a new Notification builder from an existing media session.
     * @param context
     * @param mediaSession
     * @return
     */
    fun from(activity: Activity?,
             context: Context,
             mediaSession: MediaSessionCompat?,
             notificationChannelId: String?): NotificationCompat.Builder {
        val controller = mediaSession?.controller
        val mediaMetadata = controller?.metadata
        val description = mediaMetadata?.description
        val builder = NotificationCompat.Builder(context, notificationChannelId!!)
        builder.setContentTitle(description?.title)
                .setContentText(description?.subtitle)
                .setLargeIcon(description?.iconBitmap)
                .setStyle(androidx.media.app.NotificationCompat.MediaStyle()
                        .setMediaSession(mediaSession?.sessionToken))
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setDeleteIntent(getActionIntent(context, KeyEvent.KEYCODE_MEDIA_STOP))
        val intent = Intent(context, activity?.javaClass)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)
        builder.setContentIntent(pendingIntent)
        return builder
    }

    fun getActionIntent(context: Context, mediaKeyEvent: Int): PendingIntent {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
        intent.setPackage(context.packageName)
        intent.putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, mediaKeyEvent))
        return PendingIntent.getBroadcast(context, mediaKeyEvent, intent, 0)
    }
}