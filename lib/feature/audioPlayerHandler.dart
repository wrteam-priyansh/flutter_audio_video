import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  late AudioPlayer _audioPlayer;
  Duration currentAudioDuration = Duration.zero;

  AudioPlayerHandler() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.playbackEventStream.map(_transformState).pipe(playbackState);
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

  PlaybackState _transformState(PlaybackEvent playbackEvent) {
    print("Processing state in audio handler : ${_audioPlayer.processingState}");
    return PlaybackState(
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_audioPlayer.processingState]!,
      //to show control like play/pause/next in notification
      androidCompactActionIndices: const [0, 1, 3],
      bufferedPosition: _audioPlayer.bufferedPosition,
      updatePosition: _audioPlayer.position,

      controls: [
        MediaControl.skipToPrevious,
        _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],

      errorMessage: "Error while playing audio",
      playing: _audioPlayer.playing,
      speed: _audioPlayer.speed,
    );
  }
}
