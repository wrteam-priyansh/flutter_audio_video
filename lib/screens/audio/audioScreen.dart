import 'dart:async';
import 'dart:io';

import 'package:audio_video/screens/audio/audioMenuScreen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioScreen extends StatefulWidget {
  final AudioType audioType;
  final String? audioPath;
  final bool isInPlaylist;
  final File? audioFile;
  AudioScreen({Key? key, this.audioFile, this.audioPath, required this.isInPlaylist, required this.audioType}) : super(key: key);

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late AudioPlayer _audioPlayer;
  late StreamSubscription<ProcessingState> _processingStateStreamSubscription;
  late bool _isPlaying = false;
  late Duration _audioDuration = Duration.zero;
  late bool _hasCompleted = false;
  late bool _hasError = false;
  late bool _isBuffering = false;
  late bool _isLoading = true;
  @override
  void initState() {
    initializeAudio();
    super.initState();
  }

  void initializeAudio() async {
    _audioPlayer = AudioPlayer();
    if (widget.audioType == AudioType.network) {
      try {
        var result = await _audioPlayer.setUrl(widget.audioPath!);
        _audioDuration = result ?? Duration.zero;
        _processingStateStreamSubscription = _audioPlayer.processingStateStream.listen(processingStateListener);
      } catch (e) {
        print(e.toString());
        _hasError = true;
      }
      setState(() {});
    }
  }

  void processingStateListener(ProcessingState event) {
    print(event.toString());
    if (event == ProcessingState.ready) {
      _audioPlayer.play();

      _isPlaying = true;
      _isLoading = false;
    } else if (event == ProcessingState.buffering) {
      _isBuffering = true;
    } else if (event == ProcessingState.completed) {
      _hasCompleted = true;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _processingStateStreamSubscription.cancel();
    super.dispose();
  }

  Widget _buildPlayAudioContainer() {
    if (_hasError) {
      return IconButton(
          onPressed: () {
            //
          },
          icon: Icon(Icons.error));
    }
    if (_isLoading || _isBuffering) {
      return IconButton(
          onPressed: () {
            //
          },
          icon: CircularProgressIndicator());
    }

    if (_hasCompleted) {
      return IconButton(
          onPressed: () {
            //
          },
          icon: Icon(Icons.restart_alt));
    }
    if (_isPlaying) {
      return IconButton(
          onPressed: () {
            //

            _audioPlayer.pause();
            _isPlaying = false;
            setState(() {});
          },
          icon: Icon(Icons.pause));
    }

    return IconButton(
        onPressed: () {
          _audioPlayer.play();
          _isPlaying = true;
          setState(() {});
        },
        icon: Icon(Icons.play_arrow));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrentDurationContainer(audioPlayer: _audioPlayer),
                  Spacer(),
                  _buildPlayAudioContainer(),
                  Spacer(),
                  Text("${_audioDuration.inSeconds}"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CurrentDurationContainer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  CurrentDurationContainer({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _CurrentDurationContainerState createState() => _CurrentDurationContainerState();
}

class _CurrentDurationContainerState extends State<CurrentDurationContainer> {
  late StreamSubscription<Duration> currentAudioDurationStreamSubscription;
  late Duration currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    currentAudioDurationStreamSubscription = widget.audioPlayer.positionStream.listen(currentDurationListener);
  }

  void currentDurationListener(Duration duration) {
    setState(() {
      currentDuration = duration;
    });
  }

  @override
  void dispose() {
    currentAudioDurationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("${currentDuration.inSeconds}");
  }
}
