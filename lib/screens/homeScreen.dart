// ignore_for_file: file_names
import 'package:audio_video/screens/audio/audioMenuScreen.dart';
import 'package:audio_video/screens/video/videoMenuScreen.dart';
import 'package:audio_video/screens/video/videoScreen.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const VideoMenuScreen()));
              },
              title: const Text("Video"),
            ),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AudioMenuScreen()));
              },
              title: const Text("Audio"),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoDurationSlider extends StatefulWidget {
  VideoDurationSlider({Key? key}) : super(key: key);

  @override
  _VideoDurationSliderState createState() => _VideoDurationSliderState();
}

class _VideoDurationSliderState extends State<VideoDurationSlider> {
  double currentValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
            overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
            trackHeight: 4,
            trackShape: CustomTrackShape(),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6.5,
            ),
          ),
      child: Container(
        height: 4.0,
        width: MediaQuery.of(context).size.width,
        child: Slider(
            activeColor: Colors.blue,
            inactiveColor: Colors.blue.shade100,
            value: currentValue,
            thumbColor: Colors.redAccent,
            onChanged: (value) {
              setState(() {
                currentValue = value;
              });
            }),
      ),
    );
  }
}
