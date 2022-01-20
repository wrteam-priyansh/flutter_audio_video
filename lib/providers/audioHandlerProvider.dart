import 'package:audio_video/feature/audioPlayerHandler.dart';

class AudioHandlerProvider {
  final AudioPlayerHandler _audioPlayerHandler;

  AudioPlayerHandler get audioPlayerHandler => _audioPlayerHandler;

  AudioHandlerProvider(this._audioPlayerHandler);
}
