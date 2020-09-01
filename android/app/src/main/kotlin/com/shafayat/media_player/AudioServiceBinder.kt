package com.shafayat.media_player

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.media.MediaPlayer
import android.media.MediaPlayer.OnCompletionListener
import android.media.MediaPlayer.OnPreparedListener
import android.media.session.MediaSession
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.Message
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.text.TextUtils
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import java.io.IOException

class AudioServiceBinder : Binder(), FlutterPlayer, OnPreparedListener, OnCompletionListener, MediaPlayer.OnErrorListener {
    // This is the message signal that inform audio progress updater to update audio progress.
    val UPDATE_AUDIO_PROGRESS_BAR = 1
    val UPDATE_PLAYER_STATE_TO_PAUSE = 2
    val UPDATE_PLAYER_STATE_TO_PLAY = 3
    val UPDATE_PLAYER_STATE_TO_COMPLETE = 4
    val UPDATE_AUDIO_DURATION = 5
    val UPDATE_PLAYER_STATE_TO_ERROR = 6
    private var isPlayerReady = false
    private var isBound = true
    var isMediaChanging = false
    var updateAudioProgressThread: Thread? = null

    /**
     * Whether the [MediaPlayer] broadcasted an error.
     */
    private var mReceivedError = false
    var audioFileUrl = ""
    private var title: String? = null
    private var subtitle: String? = null
    var audioPlayer: MediaPlayer? = null
        private set
    private var startPositionInMills = 0

    // This Handler object is a reference to the caller activity's Handler.
    // In the caller activity's handler, it will update the audio play progress.
    private var audioProgressUpdateHandler: Handler? = null

    /**
     * The underlying [MediaSessionCompat].
     */
    private var mMediaSessionCompat: MediaSessionCompat? = null
    var context: Context? = null
    var activity: Activity? = null



    fun setTitle(title: String?) {
        this.title = title
    }

    fun setSubtitle(subtitle: String?) {
        this.subtitle = subtitle
    }

    fun setAudioProgressUpdateHandler(audioProgressUpdateHandler: Handler?) {
        this.audioProgressUpdateHandler = audioProgressUpdateHandler
    }

    private fun setAudioMetadata() {
        val metadata: MediaMetadataCompat = MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, title)
                .putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE, subtitle)
                .build()
        mMediaSessionCompat?.setMetadata(metadata)
    }

    fun startAudio(startPositionInMills: Int) {
        this.startPositionInMills = startPositionInMills
        initAudioPlayer()
        updatePlaybackState(PlayerState.PLAYING)
        service = this
    }

    fun resume() {
        if(audioPlayer != null && audioPlayer?.isPlaying == false) {
            audioPlayer!!.start()
            updatePlaybackState(PlayerState.PLAYING)
        }
    }

    fun seekAudio(position: Int) {
        if (isPlayerReady) {
            audioPlayer!!.seekTo(position * 1000)
        }
    }

    fun pauseAudio() {
        if (audioPlayer != null) {
            if (audioPlayer!!.isPlaying) {
                audioPlayer!!.pause()
            }
            updatePlaybackState(PlayerState.PAUSED)
        }
    }

    fun reset() {
        if (audioPlayer != null) {
            if (audioPlayer!!.isPlaying) {
                audioPlayer!!.stop()
            }
            audioPlayer?.release()
            audioPlayer = null
            updatePlaybackState(PlayerState.COMPLETE)
        }
    }

    fun cleanPlayerNotification() {
        val notificationManager = context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }

    private fun initAudioPlayer() {
        try {
            if (audioPlayer == null) {
                audioPlayer = MediaPlayer()
                if (!TextUtils.isEmpty(audioFileUrl)) {
                    audioPlayer!!.setDataSource(audioFileUrl)
                }
                audioPlayer!!.setOnPreparedListener(this)
                audioPlayer!!.setOnCompletionListener(this)
                audioPlayer!!.setOnErrorListener(this)
                audioPlayer!!.prepareAsync()
            } else {
                audioPlayer?.start()
            }
        } catch (ex: IOException) {
            ex.printStackTrace()
            mReceivedError = true
        }
    }

    override fun onDestroy() {
        isBound = false
        updateAudioProgressThread?.interrupt()
        try {
            cleanPlayerNotification()
            if (audioPlayer != null) {
                if (audioPlayer!!.isPlaying) {
                    audioPlayer!!.stop()
                }
                audioPlayer!!.reset()
                audioPlayer!!.release()
                audioPlayer = null
            }
        } catch (e: Exception) { /* ignore */
        }
    }

    val currentAudioPosition: Int
        get() {
            var ret = 0
            if (audioPlayer != null) {
                ret = audioPlayer!!.currentPosition
            }
            return ret
        }

    override fun onPrepared(mp: MediaPlayer) {
        isPlayerReady = true
        isBound = true
        isMediaChanging = false
        if (startPositionInMills > 0) {
            mp.seekTo(startPositionInMills)
        }
        mp.start()
        val receiver = ComponentName(context!!.packageName,
                RemoteReceiver::class.java.name)

        mMediaSessionCompat = MediaSessionCompat(context!!,
                AudioServiceBinder::class.java.simpleName, receiver, null)
        mMediaSessionCompat?.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
                or MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS)
        mMediaSessionCompat?.setCallback(MediaSessionCallback(audioPlayer))
        mMediaSessionCompat?.setActive(true)
        setAudioMetadata()
        updatePlaybackState(PlayerState.PLAYING)

        /* This thread object will send update audio progress message to caller activity every 1 second */
        updateAudioProgressThread = object : Thread() {
            override fun run() {
                while (isBound) {
                    try {
                        if (audioPlayer != null && audioPlayer!!.isPlaying) {

                            sendDurationEvent()

                            try {
                                sleep(1000)
                            } catch (ex: InterruptedException) { /* ignore */
                            }
                        } else {
                            try {
                                sleep(100)
                            } catch (ex: InterruptedException) { /* ignore */
                            }
                        }

                    } catch (e: Exception) {
                        Log.e(TAG, "onPrepared:updateAudioProgressThread: ", e)
                    }
                }
            }
        }
        updateAudioProgressThread?.start()
    }

    override fun onCompletion(mp: MediaPlayer) {
        if (audioPlayer != null) {
            audioPlayer!!.pause()
            updatePlaybackState(PlayerState.COMPLETE)
        }
    }

    override fun onError(mp: MediaPlayer, what: Int, extra: Int): Boolean {
        updatePlaybackState(PlayerState.PAUSED)

        Log.e("AudioServiceBinder", "onPlayerError: [what=$what] [extra=$extra]", null)
        var errorMessage = ""
        errorMessage = when (what) {
            MediaPlayer.MEDIA_ERROR_IO -> "MEDIA_ERROR_IO: File or network related operation error"
            MediaPlayer.MEDIA_ERROR_MALFORMED -> "MEDIA_ERROR_MALFORMED: Bitstream is not conforming to the related" +
                    " coding standard or file spec"
            MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK -> "MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK:  The video is str" +
                    "eamed and its container is not valid for progressive playback i.e the vi" +
                    "deo's index (e.g moov atom) is not at the start of the file"
            MediaPlayer.MEDIA_ERROR_SERVER_DIED -> "MEDIA_ERROR_SERVER_DIED: Media server died"
            MediaPlayer.MEDIA_ERROR_TIMED_OUT -> "MEDIA_ERROR_TIMED_OUT: Some operation takes too long to complete," +
                    " usually more than 3-5 seconds"
            MediaPlayer.MEDIA_ERROR_UNKNOWN -> "MEDIA_ERROR_UNKNOWN: Unspecified media player error"
            MediaPlayer.MEDIA_ERROR_UNSUPPORTED -> "MEDIA_ERROR_UNSUPPORTED: Bitstream is conforming to the related c" +
                    "oding standard or file spec, but the media framework does not support th" +
                    "e feature"
            else -> "MEDIA_ERROR_UNKNOWN: Unspecified media player error"
        }
        return false
    }

    private fun sendDurationEvent() {
        val updateAudioProgressMsg = Message()
        updateAudioProgressMsg.what = UPDATE_AUDIO_PROGRESS_BAR
        audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)

        val updateAudioDurationMsg = Message()
        updateAudioDurationMsg.what = UPDATE_AUDIO_DURATION
        audioProgressUpdateHandler!!.sendMessage(updateAudioDurationMsg)
    }

    private val playbackStateBuilder: PlaybackStateCompat.Builder
        private get() {
            val playbackState: PlaybackStateCompat? = mMediaSessionCompat?.controller?.playbackState
            return if (playbackState == null) PlaybackStateCompat.Builder() else PlaybackStateCompat.Builder(playbackState)
        }

    private fun updatePlaybackState(playerState: PlayerState) {
        if (mMediaSessionCompat == null) return
        val newPlaybackState: PlaybackStateCompat.Builder = playbackStateBuilder
        val capabilities = getCapabilities(playerState)
        newPlaybackState.setActions(capabilities)
        var playbackStateCompat: Int = PlaybackStateCompat.STATE_NONE
        when (playerState) {
            PlayerState.PLAYING -> {
                playbackStateCompat = PlaybackStateCompat.STATE_PLAYING
                val updateAudioProgressMsg = Message()
                updateAudioProgressMsg.what = UPDATE_PLAYER_STATE_TO_PLAY

                // Send the message to caller activity's update audio Handler object.
                audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)
            }
            PlayerState.PAUSED -> {
                playbackStateCompat = PlaybackStateCompat.STATE_PAUSED
                val updateAudioProgressMsg = Message()
                updateAudioProgressMsg.what = UPDATE_PLAYER_STATE_TO_PAUSE
                audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)
            }
            PlayerState.BUFFERING -> {
                playbackStateCompat = PlaybackStateCompat.STATE_BUFFERING
            }
            PlayerState.IDLE -> {
                playbackStateCompat = if (mReceivedError) {
                    val updateAudioProgressMsg = Message()
                    updateAudioProgressMsg.what = UPDATE_PLAYER_STATE_TO_ERROR
                    audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)
                    PlaybackStateCompat.STATE_ERROR
                } else {
                    val updateAudioProgressMsg = Message()
                    updateAudioProgressMsg.what = UPDATE_PLAYER_STATE_TO_PAUSE
                    audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)
                    PlaybackStateCompat.STATE_STOPPED
                }
            }
            PlayerState.COMPLETE -> {
                playbackStateCompat = PlaybackStateCompat.STATE_STOPPED
                val updateAudioProgressMsg = Message()
                updateAudioProgressMsg.what = UPDATE_PLAYER_STATE_TO_COMPLETE

                // Send the message to caller activity's update audio Handler object.
                audioProgressUpdateHandler!!.sendMessage(updateAudioProgressMsg)
            }
        }
        if (audioPlayer != null) {
            newPlaybackState.setState(playbackStateCompat,
                    audioPlayer!!.currentPosition.toLong(), PLAYBACK_RATE)
        }
        mMediaSessionCompat?.setPlaybackState(newPlaybackState.build())
        updateNotification(capabilities)
    }

    @PlaybackStateCompat.Actions
    private fun getCapabilities(playerState: PlayerState): Long {
        var capabilities: Long = 0
        when (playerState) {
            PlayerState.PLAYING -> capabilities = capabilities or (PlaybackStateCompat.ACTION_PAUSE
                    or PlaybackStateCompat.ACTION_STOP)
            PlayerState.PAUSED -> capabilities = capabilities or (PlaybackStateCompat.ACTION_PLAY
                    or PlaybackStateCompat.ACTION_STOP)
            PlayerState.BUFFERING -> capabilities = capabilities or (PlaybackStateCompat.ACTION_PAUSE
                    or PlaybackStateCompat.ACTION_STOP)
            PlayerState.IDLE -> if (!mReceivedError) {
                capabilities = capabilities or PlaybackStateCompat.ACTION_PLAY
            }
        }
        return capabilities
    }

    private fun updateNotification(capabilities: Long) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
        val notificationBuilder = PlayerNotificationUtil.from(
                activity, context!!, mMediaSessionCompat, mNotificationChannelId)
        if (capabilities and PlaybackStateCompat.ACTION_PAUSE != 0L) {
            notificationBuilder.addAction(android.R.drawable.ic_media_pause, "Pause",
                    PlayerNotificationUtil.getActionIntent(context!!, KeyEvent.KEYCODE_MEDIA_PAUSE))
        }
        if (capabilities and PlaybackStateCompat.ACTION_PLAY != 0L) {
            notificationBuilder.addAction(android.R.drawable.ic_media_play, "Play",
                    PlayerNotificationUtil.getActionIntent(context!!, KeyEvent.KEYCODE_MEDIA_PLAY))
        }
        val notificationManager = context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        val notificationManager = context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelNameDisplayedToUser: CharSequence = "Notification Bar Controls"
        val importance = NotificationManager.IMPORTANCE_LOW
        val newChannel = NotificationChannel(
                mNotificationChannelId, channelNameDisplayedToUser, importance)
        newChannel.description = "All notifications"
        newChannel.setShowBadge(false)
        newChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        notificationManager.createNotificationChannel(newChannel)
    }

    /**
     * A [session.MediaSessionCompat.Callback] implementation for MediaPlayer.
     */
    private inner class MediaSessionCallback(player: MediaPlayer?) : MediaSessionCompat.Callback() {
        override fun onPause() {
            Log.d("Callback", "pause")
            audioPlayer!!.pause()
        }

        override fun onPlay() {
            audioPlayer!!.start()
        }

        override fun onSeekTo(pos: Long) {
            audioPlayer!!.seekTo(pos.toInt())
        }

        override fun onStop() {
            Log.d("Callback", "stop")
            audioPlayer!!.stop()
        }

        init {
            audioPlayer = player
        }
    }

    companion object {
        private const val TAG = "AudioServiceBinder"

        /**
         * The notification channel id we'll send notifications too
         */
        private const val mNotificationChannelId = "NotificationBarController"

        /**
         * Playback Rate for the MediaPlayer is always 1.0.
         */
        private const val PLAYBACK_RATE = 1.0f

        /**
         * The notification id.
         */
        private const val NOTIFICATION_ID = 0
        var service: AudioServiceBinder? = null
    }
}