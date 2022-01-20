import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video/providers/audioHandlerProvider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/src/provider.dart';

class AudioStreamScreen extends StatefulWidget {
  const AudioStreamScreen({Key? key}) : super(key: key);

  @override
  _AudioStreamScreenState createState() => _AudioStreamScreenState();
}

class _AudioStreamScreenState extends State<AudioStreamScreen> {
  final String radioTestLink = "https://l.top4top.io/m_807davsd1.mp3";

  bool settingAudioPlayerUrlError = false;
  bool settingAudioPlayerUrl = true;

  StreamSubscription<PlaybackState>? processingStateStreamSubscription;

  bool isPlaying = true;
  bool isBuffering = false;
  bool isAudioLoading = true;
  bool errorPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  void initAudioPlayer() async {
    await Future.delayed(Duration.zero);

    try {
      context
          .read<AudioHandlerProvider>()
          .audioPlayerHandler
          .setAudio(radioTestLink);
      setState(() {
        settingAudioPlayerUrl = false;
      });

      //setting up processing state listener
      processingStateStreamSubscription = context
          .read<AudioHandlerProvider>()
          .audioPlayerHandler
          .playbackState
          .listen(processingStateListener);
    } catch (e) {
      //
      setState(() {
        settingAudioPlayerUrl = false;
        settingAudioPlayerUrlError = true;
      });
    }
  }

  void processingStateListener(PlaybackState playbackState) {
    //
    print(playbackState.processingState);

    if (playbackState.processingState == AudioProcessingState.loading) {
      setState(() {
        isAudioLoading = true;
      });
    } else if (playbackState.processingState == AudioProcessingState.ready) {
      //
      if (isAudioLoading) {
        setState(() {
          isAudioLoading = false;
        });
      }
      //
      setState(() {
        isBuffering = false;
        isPlaying = true;
      });
    } else if (playbackState.processingState ==
        AudioProcessingState.buffering) {
      //
      setState(() {
        isBuffering = true;
      });
    }
  }

  @override
  void dispose() {
    processingStateStreamSubscription?.cancel();
    context.read<AudioHandlerProvider>().audioPlayerHandler.stop();
    super.dispose();
  }

  Widget _buildPlayPauseButton() {
    if (settingAudioPlayerUrl) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (settingAudioPlayerUrlError) {
      return Center(
        child: IconButton(onPressed: () {}, icon: Icon(Icons.error)),
      );
    }

    if (isAudioLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (isBuffering) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return IconButton(
        onPressed: () {
          //
          if (isPlaying) {
            context.read<AudioHandlerProvider>().audioPlayerHandler.pause();
            setState(() {
              isPlaying = false;
            });
          } else {
            context.read<AudioHandlerProvider>().audioPlayerHandler.play();
            setState(() {
              isPlaying = true;
            });
          }
        },
        icon: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _buildPlayPauseButton(),
      ),
    );
  }
}
