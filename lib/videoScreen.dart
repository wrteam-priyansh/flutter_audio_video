// ignore_for_file: file_names

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final String url = " https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  late FlickManager flickManager;

  void loadVideo() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(url),
    );
  }

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: const FlickVideoWithControls(
            controls: FlickVideoBuffer(
              bufferingChild: CircularProgressIndicator(
                color: Colors.yellowAccent,
              ),
            ),
          ),
          wakelockEnabled: true,
        ),
      ),
    );
  }
}
