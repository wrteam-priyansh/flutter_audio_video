import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  late AudioPlayer _audioPlayer;
  Duration currentAudioDuration = Duration.zero;

  AudioPlayerHandler() {
    _audioPlayer = AudioPlayer();
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  void disposeAudioPlayer() {
    _audioPlayer.dispose();
  }

  Future<void> setAudio(String url) async {
    _audioPlayer.dispose();
    _audioPlayer = AudioPlayer();
    try {
      var result = await audioPlayer.setUrl(url);
      currentAudioDuration = result ?? Duration.zero;
      mediaItem.add(MediaItem(id: url, title: "My audio title"));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> seek(Duration duration) async {
    await _audioPlayer.seek(duration);
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_audioPlayer.loopMode]!,
        shuffleMode: (_audioPlayer.shuffleModeEnabled) ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: event.currentIndex,
      ));
      print("Processing state in audio handler : ${_audioPlayer.processingState}");
      //   PlaybackState(
      //     processingState: const {
      //       ProcessingState.idle: AudioProcessingState.idle,
      //       ProcessingState.loading: AudioProcessingState.loading,
      //       ProcessingState.buffering: AudioProcessingState.buffering,
      //       ProcessingState.ready: AudioProcessingState.ready,
      //       ProcessingState.completed: AudioProcessingState.completed,
      //     }[_audioPlayer.processingState]!,
      //     //to show control like play/pause/next in notification
      //     androidCompactActionIndices: const [0, 1, 3],
      //     bufferedPosition: _audioPlayer.bufferedPosition,
      //     updatePosition: _audioPlayer.position,

      //     controls: [
      //       MediaControl.skipToPrevious,
      //       _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
      //       MediaControl.stop,
      //       MediaControl.skipToNext,
      //     ],

      //     errorMessage: "Error while playing audio",
      //     playing: _audioPlayer.playing,
      //     speed: _audioPlayer.speed,
      //   );
    });
  }
}
