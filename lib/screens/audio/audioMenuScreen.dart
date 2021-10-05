import 'package:audio_video/screens/audio/audioScreen.dart';
import 'package:flutter/material.dart';

enum AudioType { network, file, asset }
const String audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

class AudioMenuScreen extends StatelessWidget {
  const AudioMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AudioScreen(
                        isInPlaylist: false,
                        audioType: AudioType.network,
                        audioPath: audioUrl,
                      )));
            },
            title: Text("Network audio"),
          )
        ],
      ),
    );
  }
}
