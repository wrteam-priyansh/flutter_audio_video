// ignore_for_file: file_names

import 'dart:io';

import 'package:audio_video/screens/video/videoMenuScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

//video screen
class VideoScreen extends StatefulWidget {
  final VideoType videoType;
  final String? videoPath;
  final bool isInPlaylist;
  final File? videoFile;
  const VideoScreen({Key? key, required this.videoType, this.videoPath, required this.isInPlaylist, this.videoFile}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

const double videoDurationContainerHeight = 3.5;

class _VideoScreenState extends State<VideoScreen> with TickerProviderStateMixin {
  VideoPlayerController? videoPlayerController;
  late AnimationController menuAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  late Animation<double> menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: menuAnimationController, curve: Curves.easeInOut));

  //
  late AnimationController forwardVideoAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late Animation<double> forwardVideoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: forwardVideoAnimationController, curve: Curves.easeInOut));
  //
  late AnimationController backwardVideoAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late Animation<double> backwardVideoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: backwardVideoAnimationController, curve: Curves.easeInOut));

  bool isPlaying = false;
  bool isCompleted = false;
  bool hasError = false;

  void loadVideo() async {
    if (widget.videoType == VideoType.network) {
      videoPlayerController = VideoPlayerController.network(widget.videoPath!, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..addListener(videoListener)
        ..initialize().then((value) {
          setState(() {
            isPlaying = true;
          });

          debugPrint("Initial buffer value : ${videoPlayerController!.value.isBuffering}");
          videoPlayerController?.play();
        });
    } else if (widget.videoType == VideoType.asset) {
      videoPlayerController = VideoPlayerController.asset(widget.videoPath!, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..addListener(videoListener)
        ..initialize().then((value) {
          setState(() {
            isPlaying = true;
          });

          debugPrint("Initial buffer value : ${videoPlayerController!.value.isBuffering}");
          videoPlayerController?.play();
        });
    } else {
      videoPlayerController = VideoPlayerController.file(widget.videoFile!, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..addListener(videoListener)
        ..initialize().then((value) {
          setState(() {
            isPlaying = true;
          });

          debugPrint("Initial buffer value : ${videoPlayerController!.value.isBuffering}");
          videoPlayerController?.play();
        });
    }
  }

  void videoListener() {
    if (videoPlayerController!.value.hasError) {
      setState(() {
        hasError = true;
      });
    } else {
      if (videoPlayerController!.value.position.inSeconds == videoPlayerController!.value.duration.inSeconds) {
        setState(() {
          isCompleted = true;
        });
      }
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

  Widget _buildBackwardVideoDurationContainer(Size videoSize) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: videoSize.width * (0.25),
        ),
        child: FadeTransition(
          opacity: backwardVideoAnimation,
          child: IgnorePointer(
            ignoring: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "10s",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForwardVideoDurationContainer(Size videoSize) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: videoSize.width * (0.25),
        ),
        child: FadeTransition(
          opacity: forwardVideoAnimation,
          child: IgnorePointer(
            ignoring: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.skip_next,
                  color: Colors.white,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "10s",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContainer(Size videoSize) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: !videoPlayerController!.value.isInitialized
                ? Container(
                    width: videoSize.width,
                    height: videoSize.height,
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : SizedBox(
                    width: videoSize.width,
                    height: videoSize.height,
                    child: VideoPlayer(
                      videoPlayerController!,
                    ),
                  )),
        hasError
            ? Align(
                alignment: Alignment.center,
                child: Container(
                  width: videoSize.width,
                  height: videoSize.height,
                  color: Colors.black45,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Container(),
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
                onDoubleTapDown: (tapDownDetails) async {
                  if (tapDownDetails.globalPosition.dx <= videoSize.width * (0.5)) {
                    debugPrint("Left Side");
                    videoPlayerController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds - 10));
                    await backwardVideoAnimationController.forward();
                    await Future.delayed(Duration(milliseconds: 500));
                    backwardVideoAnimationController.reverse();
                  } else {
                    debugPrint("Right Side");
                    videoPlayerController!.seekTo(Duration(seconds: videoPlayerController!.value.position.inSeconds + 10));
                    await forwardVideoAnimationController.forward();
                    await Future.delayed(Duration(milliseconds: 500));
                    forwardVideoAnimationController.reverse();
                  }
                },
                child: Container(
                  width: videoSize.width,
                  height: videoSize.height,
                  color: Colors.transparent,
                ),
              )
            : Container(),
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
                radius: 27.5,
                child: Icon(
                  isCompleted
                      ? Icons.restart_alt
                      : isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: videoPlayerController!.value.isInitialized ? VideoBufferingContainer(videoPlayerController: videoPlayerController!) : Container(),
        ),
        _buildBackwardVideoDurationContainer(videoSize),
        _buildForwardVideoDurationContainer(videoSize),

        //videoBottomMenu

        Align(
          alignment: Alignment.bottomLeft,
          child: SlideTransition(
            position: menuAnimation.drive<Offset>(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7.5),
              child: videoPlayerController!.value.isInitialized
                  ? VideoBufferDurationContainer(
                      videoPlayerController: videoPlayerController!,
                      videoSize: videoSize,
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
              padding: const EdgeInsets.only(bottom: 7.5),
              child: videoPlayerController!.value.isInitialized
                  ? VideoDurationContainer(
                      videoPlayerController: videoPlayerController!,
                      videoSize: videoSize,
                      menuAnimationController: menuAnimationController,
                    )
                  : Container(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildVideoContainer(MediaQuery.of(context).size);
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * (0.4), child: _buildVideoContainer(Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * (0.4)))),
            ],
          );
        },
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
            backgroundColor: Colors.white,
            child: Center(child: CircularProgressIndicator()),
            radius: 27.5,
          )
        : Container();
  }
}

class VideoBufferDurationContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final Size videoSize;
  const VideoBufferDurationContainer({Key? key, required this.videoPlayerController, required this.videoSize}) : super(key: key);

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
      width: widget.videoSize.width * bufferDurationWidthPercentage,
      height: videoDurationContainerHeight,
    );
  }
}

class VideoDurationContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final Size videoSize;
  final AnimationController menuAnimationController;
  const VideoDurationContainer({Key? key, required this.videoPlayerController, required this.menuAnimationController, required this.videoSize}) : super(key: key);
  @override
  _VideoDurationContainerState createState() => _VideoDurationContainerState();
}

class _VideoDurationContainerState extends State<VideoDurationContainer> {
  double currentValue = 0.0;
  double thumbRadius = 0.0;
  late Animation<double> thumbRadiusAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(widget.menuAnimationController);

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
    currentValue = widget.videoPlayerController.value.position.inSeconds.toDouble();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.menuAnimationController,
      builder: (context, child) {
        return SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                  trackHeight: videoDurationContainerHeight,
                  trackShape: CustomTrackShape(),
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: thumbRadiusAnimation.value,
                  ),
                ),
            child: child!);
      },
      child: Container(
        height: videoDurationContainerHeight,
        width: MediaQuery.of(context).size.width,
        child: Slider(
            max: widget.videoPlayerController.value.duration.inSeconds.toDouble(),
            min: 0.0,
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
            value: currentValue,
            thumbColor: Colors.blueAccent,
            onChanged: (value) {
              setState(() {
                currentValue = value;
              });
            }),
      ),
    );
  }
}

class VideoBottomMenuContainer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  VideoBottomMenuContainer({Key? key, required this.videoPlayerController}) : super(key: key);

  @override
  _VideoBottomMenuContainerState createState() => _VideoBottomMenuContainerState();
}

class _VideoBottomMenuContainerState extends State<VideoBottomMenuContainer> {
  String currentTime = "";

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
    //currentValue = widget.videoPlayerController.value.position.inSeconds.toDouble();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row();
  }
}

class CustomTrackShape extends RectangularSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    return Offset(offset.dx, offset.dy) & Size(parentBox.size.width, sliderTheme.trackHeight!);
  }
}
