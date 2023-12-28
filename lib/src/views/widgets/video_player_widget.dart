import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/video_play_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  String path;
  VideoPlayerWidget({required this.path, super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  VideoPlayProvider? _playProvider;
  @override
  void initState() {
    super.initState();
    _playProvider = Provider.of<VideoPlayProvider>(context, listen: false);
    _controller = VideoPlayerController.file(File(widget.path));
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller.value.isInitialized) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      _controller = VideoPlayerController.file(File(widget.path))..initialize();
      _controller.addListener(() {
        if (_controller.value.isPlaying) {
          _playProvider!.setVideoStatus(VideoStatus.playing);
        } else {
          _playProvider!.setVideoStatus(VideoStatus.pause);
        } 
        if (mounted) {
          setState(() {});
        }
      });
    }
    return MouseRegion(
      onEnter: (_) {
        _playProvider!.setHideBlur(true);
      },
      onExit: (_) {
        _playProvider!.setHideBlur(false);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              (_controller.value.isInitialized)
                  ? Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${Utils.instance().formatDuration(_controller.value.position)}"
                            " / "
                            "${Utils.instance().formatDuration(_controller.value.duration)}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: _controller.value.position.inSeconds /
                                _controller.value.duration.inSeconds,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(10),
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.defaultPurpleColor),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              _buildActionVideo()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionVideo() {
    return Consumer<VideoPlayProvider>(builder: (context, provider, child) {
      if (_controller.value.duration == _controller.value.position) {
        Future.delayed(Duration.zero, () {
          _playProvider!.setVideoStatus(VideoStatus.endVideo);
          _playProvider!.setHideBlur(true);
        });
      }
      return (provider.hideBlur && _controller.value.isInitialized)
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color.fromARGB(144, 129, 127, 127),
                ),
                (provider.videoStatus == VideoStatus.endVideo)
                    ? InkWell(
                        onTap: () {
                          _controller.play();
                        },
                        splashColor: Colors.transparent,
                        child: const Icon(
                          Icons.replay_circle_filled_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : const SizedBox(),
                (provider.videoStatus == VideoStatus.pause)
                    ? InkWell(
                        onTap: () {
                          _controller.play();
                        },
                        splashColor: Colors.transparent,
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : const SizedBox(),
                (provider.videoStatus == VideoStatus.playing)
                    ? InkWell(
                        onTap: () {
                          _controller.pause();
                        },
                        splashColor: Colors.transparent,
                        child: const Icon(
                          Icons.pause_circle_filled_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : const SizedBox()
              ],
            )
          : const SizedBox();
    });
  }
}
