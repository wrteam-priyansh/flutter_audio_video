// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with TickerProviderStateMixin {
  final String url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  VideoPlayerController? videoPlayerController;
  late AnimationController menuAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late Animation<double> menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: menuAnimationController, curve: Curves.easeInOut));
  // ignore: prefer_final_fields
  bool isBuffering = false;
  bool isPlaying = false;
  bool isCompleted = false;

  void loadVideo() async {
    videoPlayerController = VideoPlayerController.network(url, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..addListener(videoListener)
      ..initialize().then((value) {
        setState(() {});

        debugPrint("Initial buffer value : ${videoPlayerController!.value.isBuffering}");
        //videoPlayerController?.play();
      });
  }

  void videoListener() {
    if (videoPlayerController!.value.position.inSeconds == videoPlayerController!.value.duration.inSeconds) {
      setState(() {
        isCompleted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  @override
  void dispose() {
    videoPlayerController?.removeListener(videoListener);
    videoPlayerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: !videoPlayerController!.value.isInitialized
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: VideoPlayer(
                        videoPlayerController!,
                      ),
                    )),
          videoPlayerController!.value.isInitialized
              ? GestureDetector(
                  onTap: () {
                    if (menuAnimationController.isCompleted) {
                      menuAnimationController.reverse();
                    } else {
                      menuAnimationController.forward();
                    }
                  },
                  onDoubleTap: () {
                    //debugPrint("Double tapped ");
                  },
                  onDoubleTapDown: (tapDownDetails) {
                    if (tapDownDetails.globalPosition.dx <= MediaQuery.of(context).size.width * (0.5)) {
                      debugPrint("Left Side");
                      videoPlayerController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds - 10));
                      //videoPlayerController!.play();
                    } else {
                      debugPrint("Right Side");
                      videoPlayerController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds + 10));
                      //videoPlayerController!.play();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
                )
              : Container(),
          Center(
            child: isBuffering ? const CircularProgressIndicator() : const SizedBox(),
          ),
          Align(
            alignment: Alignment.center,
            child: videoPlayerController!.value.isInitialized ? VideoBufferingContainer(videoPlayerController: videoPlayerController!) : Container(),
          ),
          Align(
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: menuAnimation,
              child: GestureDetector(
                onTap: () async {
                  if (isCompleted) {
                    await videoPlayerController!.seekTo(Duration.zero);
                    videoPlayerController!.play();
                    setState(() {
                      isCompleted = false;
                      isPlaying = true;
                    });
                  } else {
                    if (isPlaying) {
                      videoPlayerController!.pause();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    } else {
                      videoPlayerController!.play();
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    }
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(
                    isCompleted
                        ? Icons.restart_alt
                        : isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: menuAnimation.drive<Offset>(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(color: Colors.white38, width: MediaQuery.of(context).size.width, height: 5),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SlideTransition(
              position: menuAnimation.drive<Offset>(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: videoPlayerController!.value.isInitialized
                    ? VideoBufferDurationContainer(
                        videoPlayerController: videoPlayerController!,
                      )
                    : Container(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SlideTransition(
              position: menuAnimation.drive<Offset>(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: videoPlayerController!.value.isInitialized ? VideoDurationContainer(videoPlayerController: videoPlayerController!) : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoBufferingContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const VideoBufferingContainer({Key? key, required this.videoPlayerController}) : super(key: key);

  @override
  _VideoBufferingContainerState createState() => _VideoBufferingContainerState();
}

class _VideoBufferingContainerState extends State<VideoBufferingContainer> {
  bool isVideoBuffering = false;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(videoBufferDurationListener);
  }

  @override
  void dispose() {
    widget.videoPlayerController.removeListener(videoBufferDurationListener);
    super.dispose();
  }

  void videoBufferDurationListener() {
    if (widget.videoPlayerController.value.buffered.isNotEmpty) {
      if (widget.videoPlayerController.value.buffered.last.end.inSeconds == widget.videoPlayerController.value.position.inSeconds) {
        if (widget.videoPlayerController.value.position.inSeconds != widget.videoPlayerController.value.duration.inSeconds) {
          setState(() {
            isVideoBuffering = true;
          });
        }
      } else {
        setState(() {
          isVideoBuffering = false;
        });
      }
    } else {
      setState(() {
        isVideoBuffering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isVideoBuffering
        ? const CircleAvatar(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
            radius: 35,
          )
        : Container();
  }
}

class VideoBufferDurationContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const VideoBufferDurationContainer({Key? key, required this.videoPlayerController}) : super(key: key);

  @override
  _VideoBufferDurationContainerState createState() => _VideoBufferDurationContainerState();
}

class _VideoBufferDurationContainerState extends State<VideoBufferDurationContainer> {
  double bufferDurationWidthPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(videoBufferDurationListener);
  }

  @override
  void dispose() {
    widget.videoPlayerController.removeListener(videoBufferDurationListener);
    super.dispose();
  }

  void videoBufferDurationListener() {
    if (widget.videoPlayerController.value.buffered.isNotEmpty) {
      bufferDurationWidthPercentage = widget.videoPlayerController.value.buffered.last.end.inSeconds / widget.videoPlayerController.value.duration.inSeconds;
    } else {
      bufferDurationWidthPercentage = 0.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      width: MediaQuery.of(context).size.width * bufferDurationWidthPercentage,
      height: 5,
    );
  }
}

class VideoDurationContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const VideoDurationContainer({Key? key, required this.videoPlayerController}) : super(key: key);
  @override
  _VideoDurationContainerState createState() => _VideoDurationContainerState();
}

class _VideoDurationContainerState extends State<VideoDurationContainer> {
  double durationWidthPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController.addListener(videoDurationListener);
  }

  @override
  void dispose() {
    widget.videoPlayerController.removeListener(videoDurationListener);
    super.dispose();
  }

  void videoDurationListener() {
    durationWidthPercentage = widget.videoPlayerController.value.position.inSeconds / widget.videoPlayerController.value.duration.inSeconds;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * durationWidthPercentage,
      height: 5,
    );
  }
}
