import 'package:cloud/channels/app_web_channel.dart';
import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../utils/screen_size.dart';

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
    if(widget.fileModel.isAvailableOffline) {
      player.open(Media(widget.fileModel.offlinePath), play: false);
    }
    else {
      player.open(Media("${appWebChannel.serverAddress}/cloud/files/${widget.fileModel.id}/download", httpHeaders: {
        "Authorization": appWebChannel.token
      }), play: false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = videoController.player.state.videoParams.aspect ?? (16 / 9);
    final screenSize = MediaQuery.sizeOf(context);
    final video = Video(
      aspectRatio: aspectRatio,
      controller: videoController
    );

    if(isDesktop()) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: screenSize.width - 100,
          height: screenSize.height - 100,
          child: video,
        ),
      );
    }

    return video;
  }
}