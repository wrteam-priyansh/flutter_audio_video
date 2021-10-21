import 'package:audio_service/audio_service.dart';
import 'package:audio_video/feature/audioPlayerHandler.dart';
import 'package:audio_video/feature/musicPlayerCubit.dart';
import 'package:audio_video/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
  ]);
  final audioHandler = await AudioService.init<AudioPlayerHandler>(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      notificationColor: Colors.red,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
    ),
  );
  runApp(MyApp(
    audioHandler: audioHandler,
  ));
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  MyApp({Key? key, required this.audioHandler}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MusicPlayerCubit>(create: (_) => MusicPlayerCubit(audioHandler)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
