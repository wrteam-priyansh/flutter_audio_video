import 'package:audio_service/audio_service.dart';
import 'package:audio_video/feature/audioPlayerHandler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

//https://exampledomain.com/song.mp3

abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlayerLoading extends MusicPlayerState {}

class MusicPlayerSuccess extends MusicPlayerState {
  final AudioPlayer audioPlayer;
  final Duration audioDuration;

  MusicPlayerSuccess({required this.audioDuration, required this.audioPlayer});
}

class MusicPlayerFailure extends MusicPlayerState {
  final String errorMessage;

  MusicPlayerFailure(this.errorMessage);
}

class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  final AudioPlayerHandler _audioHandler;
  MusicPlayerCubit(this._audioHandler) : super(MusicPlayerInitial()) {}

  void initPlayer(String url) async {
    emit(MusicPlayerLoading());
    try {
      await _audioHandler.setAudio(url);

      emit(MusicPlayerSuccess(
        audioDuration: _audioHandler.currentAudioDuration,
        audioPlayer: _audioHandler.audioPlayer,
      ));
    } catch (e) {
      print(e.toString());
      emit(MusicPlayerFailure("Error while plyaing music"));
    }
  }

  AudioPlayerHandler get audioPlayerHandler => _audioHandler;

  @override
  Future<void> close() async {
    _audioHandler.disposeAudioPlayer();
    super.close();
  }
}
