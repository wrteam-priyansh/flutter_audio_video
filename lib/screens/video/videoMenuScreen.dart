// ignore_for_file: file_names
import 'package:audio_video/screens/video/videoScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum VideoType { network, file, asset }
const String url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

class VideoMenuScreen extends StatelessWidget {
  const VideoMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videos"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const VideoScreen(
                        isInPlaylist: false,
                        videoType: VideoType.network,
                        videoPath: url,
                      )));
            },
            title: const Text("Network video"),
          ),
          ListTile(
            onTap: () {},
            title: const Text("Asset video"),
          ),
          ListTile(
            onTap: () {},
            title: const Text("File video"),
          ),
          ListTile(
            onTap: () {
              //
              //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VideoScreen()));
            },
            title: const Text("Network video playlist"),
          ),
          ListTile(
            onTap: () {},
            title: const Text("File video playlist"),
          ),
        ],
      ),
    );
  }
}
