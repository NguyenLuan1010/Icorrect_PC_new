import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/video_play_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../providers/submit_video_provider.dart';
import '../../../utils/utils.dart';
import '../../widgets/video_player_widget.dart';

class SubmitVideoAuth extends StatefulWidget {
  File savedFile;
  Function onClickSubmit;
  Function onClickRecordNewVideo;
  SubmitVideoAuth(
      {required this.onClickSubmit,
      required this.onClickRecordNewVideo,
      required this.savedFile,
      super.key});

  @override
  State<SubmitVideoAuth> createState() => _SubmitVideoAuthState();
}

class _SubmitVideoAuthState extends State<SubmitVideoAuth> {
  late VideoPlayerController _controller;
  SubmitVideoAuthProvider? _submitVideoAuthProvider;

  @override
  void initState() {
    super.initState();
    _submitVideoAuthProvider =
        Provider.of<SubmitVideoAuthProvider>(context, listen: false);
    _controller = VideoPlayerController.file(widget.savedFile);
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
      _controller = VideoPlayerController.file(widget.savedFile)..initialize();
      _controller.addListener(() {
        if (_controller.value.isPlaying) {
          _submitVideoAuthProvider!.setVideoStatus(VideoStatus.playing);
        } else {
          _submitVideoAuthProvider!.setVideoStatus(VideoStatus.pause);
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
    return Consumer<SubmitVideoAuthProvider>(
        builder: (context, provider, child) {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(
                child: MouseRegion(
              onEnter: (_) {
                _submitVideoAuthProvider!.setHideBlur(true);
              },
              onExit: (_) {
                _submitVideoAuthProvider!.setHideBlur(false);
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
                                    value: _controller
                                            .value.position.inSeconds /
                                        _controller.value.duration.inSeconds,
                                    minHeight: 5,
                                    borderRadius: BorderRadius.circular(10),
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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
            )),
            Expanded(
                child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    Utils.instance().multiLanguage(
                        StringConstants.confirm_submit_video_auth_content),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.defaultPurpleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  Stack(
                    children: [
                      Visibility(
                          visible: !provider.isSubmitLoading,
                          child: Column(
                            children: [
                              _submitVideoButton(),
                              _deniedSubmitVideoButton()
                            ],
                          )),
                      Visibility(
                        visible: provider.isSubmitLoading,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.defaultPurpleColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      );
    });
  }

  Widget _buildActionVideo() {
    return Consumer<SubmitVideoAuthProvider>(
        builder: (context, provider, child) {
      if (_controller.value.duration == _controller.value.position) {
        Future.delayed(Duration.zero, () {
          _submitVideoAuthProvider!.setVideoStatus(VideoStatus.endVideo);
          _submitVideoAuthProvider!.setHideBlur(true);
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

  Widget _submitVideoButton() {
    double w = MediaQuery.of(context).size.width;
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        _submitVideoAuthProvider!.setIsSubmitLoading(true);
        widget.onClickSubmit();
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.defaultPurpleColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          Utils.instance().multiLanguage(StringConstants.submit_now_title),
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _deniedSubmitVideoButton() {
    double w = MediaQuery.of(context).size.width;
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () async {
        if (widget.savedFile.existsSync()) {
          await widget.savedFile.delete();
        }
        widget.onClickRecordNewVideo();
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.defaultPurpleColor, width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          Utils.instance()
              .multiLanguage(StringConstants.record_new_video_title),
          style: const TextStyle(
            color: AppColors.defaultPurpleColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
