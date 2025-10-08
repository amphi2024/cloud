import 'package:cloud/channels/app_web_channel.dart';
import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {

  final FileModel fileModel;
  const VideoPlayer({super.key, required this.fileModel});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {

  final Player player = Player();
  late VideoController videoController;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    videoController = VideoController(player);
    player.open(Media("${appWebChannel.serverAddress}/cloud/files/${widget.fileModel.id}/download", httpHeaders: {
      "Authorization": appWebChannel.token
    }), play: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Video(
      height: width / (16 / 9),
      controller: videoController
    );
  }
}