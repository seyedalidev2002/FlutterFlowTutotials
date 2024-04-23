// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoChatWidget extends StatefulWidget {
  const VideoChatWidget({
    super.key,
    this.width,
    this.height,
    required this.channelName,
    required this.appId,
    required this.token,
  });

  final double? width;
  final double? height;
  final String channelName;
  final String appId;
  final String token;

  @override
  State<VideoChatWidget> createState() => _VideoChatWidgetState();
}

class _VideoChatWidgetState extends State<VideoChatWidget> {
  bool isCameraOff = false;
  bool isMuted = false;
  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // Check and request necessary permissions: microphone and camera
    // This is required for mobile apps; permissions are typically managed by the browser for web apps
    if (!kIsWeb) {
      await [Permission.microphone, Permission.camera].request();
    }

    // Create the Agora engine using the App ID provided by Agora.io
    _engine = await RtcEngine.create(widget.appId);

    // Enable the video module
    await _engine!.enableVideo();

    // Setup the video configuration (you can adjust the resolution, frame rate, bitrate, etc. as needed)
    await _engine!.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      frameRate: VideoFrameRate.Fps30,
      orientationMode: VideoOutputOrientationMode.Adaptative,
    ));

    // Define the event handler to handle events such as user joining, user offline, etc.
    _engine!.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print("Local user $uid joined channel: $channel");
        setState(() {
          _localUserJoined = true;
        });
      },
      userJoined: (int uid, int elapsed) {
        print("Remote user $uid joined");
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        print("Remote user $uid left channel");
        setState(() {
          if (_remoteUid == uid) {
            _remoteUid = null;
          }
        });
      },
    ));

    // Join the channel with a token, channel name, and optional additional information (empty string here)
    await _engine!.joinChannel(widget.token, widget.channelName, null, 0);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _engine?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 150,
              child: Center(child: RtcLocalView.SurfaceView()),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _toolbar(),
          ),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FloatingActionButton(
          onPressed: _onToggleCamera,
          child: Icon(isCameraOff ? Icons.videocam_off : Icons.videocam),
        ),
        FloatingActionButton(
          onPressed: _onToggleMute,
          child: Icon(isMuted ? Icons.mic_off : Icons.mic),
        ),
        FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.call_end),
          backgroundColor: Colors.red,
        ),
      ],
    );
  }

  void _onToggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
      _engine?.enableLocalVideo(isCameraOff);
    });
  }

  void _onToggleMute() {
    setState(() {
      isMuted = !isMuted;
      _engine?.muteLocalAudioStream(isMuted);
    });
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid!,
        channelId: widget.channelName,
      );
    } else {
      return Text("Waiting for other participant...");
    }
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
