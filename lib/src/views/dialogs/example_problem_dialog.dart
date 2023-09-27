import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/api_urls.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/my_test_models/skill_problem_model.dart';

class ExampleProblemDialog extends Dialog {
  final BuildContext context;
  final SkillProblem problem;
  final MyTestProvider provider;

  ExampleProblemDialog(
      {required this.context,
      required this.problem,
      required this.provider,
      super.key});

  @override
  double? get elevation => 0;

  @override
  Color? get backgroundColor => Colors.white;
  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _showDialog();

  static VideoPlayerController playerController =
      VideoPlayerController.file(File(""))..initialize();

  Widget _showDialog() {
    AudioPlayer audioPlayer = AudioPlayer();

    audioPlayer.onPlayerComplete.listen((event) {
      provider.setPlayAudioExample(true);
    });
    return SingleChildScrollView(
        child: Container(
      width: 500,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                provider.setPlayAudioExample(true);
                if (playerController.value.isPlaying) {
                  playerController.pause();
                }
                playerController.dispose();

                audioPlayer.stop();
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.cancel_outlined),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Example",
                  style: TextStyle(
                      color: AppColors.orangeDark,
                      fontSize: 25,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("You should say : ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          Text(problem.exampleText,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _isVideoFile(problem.fileName)
                          ? _buildVideoWidget(problem)
                          : _buildAudioWidget(audioPlayer, problem),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildVideoWidget(SkillProblem skillProblem) {
    String url = fileEP(skillProblem.fileName);
    playerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize();

    playerController.play();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Video Example : ",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            height: 150,
            child: AspectRatio(
              aspectRatio: playerController.value.aspectRatio,
              child: VideoPlayer(playerController),
            ))
      ],
    );
  }

  Widget _buildAudioWidget(AudioPlayer audioPlayer, SkillProblem skillProblem) {
    return Row(
      children: [
        const Text("Audio Example : ",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Consumer<MyTestProvider>(builder: (context, appState, child) {
          return (appState.playAudioExample)
              ? InkWell(
                  onTap: () async {
                    provider.setPlayAudioExample(false);
                    _playAudio(audioPlayer, skillProblem.fileName);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Click To Play',
                          style: TextStyle(color: Colors.green, fontSize: 13)),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () async {
                    provider.setPlayAudioExample(true);
                    audioPlayer.stop();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Stop',
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  ),
                );
        }),
      ],
    );
  }

  bool _isVideoFile(String fileName) {
    final type = fileName.split('.');
    return type.last == 'mp4';
  }

  void _playAudio(AudioPlayer audioPlayer, String fileName) {
    String url = fileEP(fileName);

    audioPlayer.play(UrlSource(url));
    audioPlayer.setVolume(2.5);
  }
}
