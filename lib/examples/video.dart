import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  const Video({Key? key}) : super(key: key);

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  final videoPlayerController = VideoPlayerController.asset(
    'assets/videos/butterfly.mp4',
  );

  @override
  void initState() {
    super.initState();
    videoPlayerController.initialize().then((value) => setState(() {}));
    videoPlayerController.setLooping(true);
    videoPlayerController.setVolume(0);
    videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: videoPlayerController.value.isInitialized
            ? videoPlayerController.value.aspectRatio
            : 1,
        child: VideoPlayer(videoPlayerController),
      );
}
