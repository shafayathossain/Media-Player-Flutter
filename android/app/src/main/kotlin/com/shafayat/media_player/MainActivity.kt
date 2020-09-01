package com.shafayat.media_player

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Handler
import android.os.IBinder
import android.os.Message
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.lang.ref.WeakReference
import java.util.*

class MainActivity: FlutterActivity(), MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val TAG = "AudioPlayer"

    private var audioServiceBinder: AudioServiceBinder? = null

    private var audioProgressUpdateHandler: Handler? = null

    private var eventSink: EventSink? = null

    private val mActivity: Activity? = null

    private val mContext: Context? = null

    private var audioURL: String? = null

    private var title: String? = null

    private var subtitle: String? = null

    private var startPositionInMills = 0

    private var mMediaNotificationManagerService: MediaNotificationManagerService? = null

    private var mIsBoundMediaNotificationManagerService = false

    private var mediaDuration = 0

    private val serviceConnection: ServiceConnection = object : ServiceConnection {

        override fun onServiceConnected(componentName: ComponentName, iBinder: IBinder) {

            /* Cast and assign background service's onBind method returned iBinder object */
            audioServiceBinder = iBinder as AudioServiceBinder
            audioServiceBinder?.activity = activity
            audioServiceBinder?.context = context
            audioServiceBinder?.audioFileUrl = audioURL ?: ""
            audioServiceBinder?.setTitle(title)
            audioServiceBinder?.setSubtitle(subtitle)
            audioServiceBinder?.setAudioProgressUpdateHandler(audioProgressUpdateHandler)
            audioServiceBinder?.startAudio(startPositionInMills)
            doBindMediaNotificationManagerService()
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            io.flutter.Log.d("Service disconnected", componentName.shortClassName)
        }
    }

    private val mMediaNotificationManagerServiceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName, service: IBinder) {
            mMediaNotificationManagerService = (service as MediaNotificationManagerService.MediaNotificationManagerServiceBinder)
                    .service
            mMediaNotificationManagerService?.setActivePlayer(audioServiceBinder)
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            mMediaNotificationManagerService = null
        }
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        audioProgressUpdateHandler = IncomingMessageHandler(this)
        MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.shafayat.mediaPlayer/audio")
                .setMethodCallHandler(this)

        EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.shafayat.mediaPlayer/audio_event",
                JSONMethodCodec.INSTANCE)
                .setStreamHandler(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unBoundAudioService()
            doUnbindMediaNotificationManagerService()

            /* reset media duration */mediaDuration = 0
        } catch (e: java.lang.Exception) { /* ignore */
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        print(call.method)
        when (call.method) {
            "play" -> {
                play(call.arguments)
                result.success(true)
            }
            "resume" -> {
                resume()
                result.success(true)
            }
            "pause" -> {
                pause()
                result.success(true)
            }
            "reset" -> {
                reset()
                result.success(true)
            }
            "seekTo" -> {
                seekTo(call.arguments)
                result.success(true)
            }
            "dispose" -> {
                onDestroy()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }

    private fun notifyDartOnPlay() {
        try {
            val message = JSONObject()
            message.put("name", "onPlay")
            eventSink?.success(message)
        } catch (e: java.lang.Exception) {
            Log.e(TAG, "notifyDartOnPlay: ", e)
        }
    }

    private fun notifyDartOnPause() {
        try {
            val message = JSONObject()
            message.put("name", "onPause")
            eventSink!!.success(message)
        } catch (e: java.lang.Exception) {
            Log.e(TAG, "notifyDartOnPause: ", e)
        }
    }

    private fun notifyDartOnComplete() {
        try {
            val message = JSONObject()
            message.put("name", "onComplete")
            eventSink!!.success(message)
        } catch (e: java.lang.Exception) {
            Log.e(TAG, "notifyDartOnComplete: ", e)
        }
    }

    private fun notifyDartOnError(errorMessage: String) {
        try {
            val message = JSONObject()
            message.put("name", "onError")
            message.put("error", errorMessage)
            eventSink!!.success(message)
        } catch (e: java.lang.Exception) {
            Log.e(TAG, "notifyDartOnError: ", e)
        }
    }

    private fun play(arguments: Any) {
        val args = arguments as HashMap<String, Any>
        val newUrl = args["url"] as String?
        var mediaChanged = true
        if (audioURL != null) {
            mediaChanged = audioURL != newUrl
        }
        audioURL = newUrl
        title = args["title"] as String?
        subtitle = args["subtitle"] as String?
        try {
            startPositionInMills = args["position"] as Int
        } catch (e: Exception) { /* ignore */
        }
        if (audioServiceBinder != null) {
            if (mediaChanged) {
                try {
                    audioServiceBinder?.reset()
                } catch (e: Exception) { /* ignore */
                }
                audioServiceBinder?.isMediaChanging = true
            }
            audioServiceBinder?.audioFileUrl = audioURL ?: ""
            audioServiceBinder?.setTitle(title)
            audioServiceBinder?.setSubtitle(subtitle)
            audioServiceBinder?.startAudio(startPositionInMills)
        } else {
            bindAudioService()
        }
        notifyDartOnPlay()
    }

    private fun resume() {
        if(audioServiceBinder != null) {
            audioServiceBinder!!.resume()
        } else {
            bindAudioService()
        }
        notifyDartOnPlay()
    }

    private fun pause() {
        if (audioServiceBinder != null) {
            audioServiceBinder!!.pauseAudio()
        }
    }

    private fun reset() {
        if (audioServiceBinder != null) {
            audioServiceBinder!!.reset()
            audioServiceBinder!!.cleanPlayerNotification()
            audioServiceBinder = null
        }
    }

    private fun seekTo(arguments: Any) {
        try {
            val args = arguments as HashMap<String, Double>
            val position = args["second"]
            if (audioServiceBinder != null && position != null) {
                audioServiceBinder!!.seekAudio(position.toInt())
            }
        } catch (e: java.lang.Exception) {
            notifyDartOnError(e.message!!)
        }
    }

    private fun onDuration() {
        try {
            if ( audioServiceBinder != null && audioServiceBinder!!.audioPlayer != null &&
                    !audioServiceBinder!!.isMediaChanging ) {
                val newDuration: Int = audioServiceBinder?.audioPlayer?.duration ?: 0
                if (newDuration != mediaDuration) {
                    mediaDuration = newDuration
                    val message = JSONObject()
                    message.put("name", "onDuration")
                    message.put("duration", mediaDuration)
                    eventSink!!.success(message)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e(TAG, "onDuration: ", e)
        }
    }

    private fun bindAudioService() {
        if (audioServiceBinder == null) {
            val intent = Intent(context, AudioService::class.java)
            bindService(intent, serviceConnection, BIND_AUTO_CREATE)
        }
    }

    private fun unBoundAudioService() {
        if (audioServiceBinder != null) {
            unbindService(serviceConnection)
            reset()
        }
    }

    private fun doBindMediaNotificationManagerService() {
        val service = Intent(this.context,
                MediaNotificationManagerService::class.java)
        bindService(service, mMediaNotificationManagerServiceConnection,
                BIND_AUTO_CREATE)
        mIsBoundMediaNotificationManagerService = true
        this.context.startService(service)
    }

    private fun doUnbindMediaNotificationManagerService() {
        if (mIsBoundMediaNotificationManagerService) {
            unbindService(mMediaNotificationManagerServiceConnection)
            mIsBoundMediaNotificationManagerService = false
        }
    }

    internal class IncomingMessageHandler(service: MainActivity) : Handler() {

        private val mService: WeakReference<MainActivity>

        override fun handleMessage(msg: Message) {

            val service = mService.get()
            if (service != null && service.audioServiceBinder != null) {

                /* The update process message is sent from AudioServiceBinder class's thread object */
                if (msg.what == service.audioServiceBinder?.UPDATE_AUDIO_PROGRESS_BAR) {
                    try {
                        val position: Int = service.audioServiceBinder?.currentAudioPosition ?: 0
                        val duration: Int = service.audioServiceBinder?.audioPlayer?.duration ?: 0
                        if (position <= duration) {
                            val message = JSONObject()
                            message.put("name", "onTime")
                            message.put("time",
                                    (service.audioServiceBinder?.currentAudioPosition ?: 0) / 1000)
                            service.eventSink?.success(message)
                        }
                    } catch (e: Exception) { /* ignore */
                        e.printStackTrace()
                    }
                } else if (msg.what == service.audioServiceBinder?.UPDATE_PLAYER_STATE_TO_PAUSE) {
                    service.notifyDartOnPause()
                } else if (msg.what == service.audioServiceBinder?.UPDATE_PLAYER_STATE_TO_PLAY) {
                    service.notifyDartOnPlay()
                } else if (msg.what == service.audioServiceBinder?.UPDATE_PLAYER_STATE_TO_COMPLETE) {
                    service.notifyDartOnComplete()
                } else if (msg.what == service.audioServiceBinder?.UPDATE_PLAYER_STATE_TO_ERROR) {
                    service.notifyDartOnError(msg.obj.toString())
                } else if (msg.what == service.audioServiceBinder?.UPDATE_AUDIO_DURATION) {
                    service.onDuration()
                }
            }
        }

        init {
            mService = WeakReference(service)
        }
    }
}
