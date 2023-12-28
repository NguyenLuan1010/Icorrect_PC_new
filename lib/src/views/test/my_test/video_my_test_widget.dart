import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/presenters/test_room_simulator_presenter.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/simulator_test_models/playlist_model.dart';
import '../../../providers/video_play_provider.dart';

class VideoMyTestWidget extends StatefulWidget {
  TestDetailModel testDetailModel;
  VideoMyTestWidget({required this.testDetailModel, super.key});

  @override
  State<VideoMyTestWidget> createState() => _VideoMyTestWidgetState();
}

class _VideoMyTestWidgetState extends State<VideoMyTestWidget> {
  double w = 0;
  double h = 0;
  TestRoomSimulatorPresenter? _testRoomSimulatorPresenter;
  VideoPlayerController? _videoPlayerController;
  MyTestProvider? _myTestProvider;
  AudioPlayer? _audioPlayer;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _testRoomSimulatorPresenter = TestRoomSimulatorPresenter(null);
    _myTestProvider = Provider.of<MyTestProvider>(context, listen: false);

    _prepareData();
  }

  void _prepareData() async {
    Future.delayed(Duration.zero, () {
      List<PlayListModel> playsList =
          _testRoomSimulatorPresenter!.getPlayList(widget.testDetailModel);
      _myTestProvider!.setPlayList(playsList);

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
          'https://icorrect-audio.s3.ap-southeast-1.amazonaws.com/class/bankclass8new/l8-u1-03.mp4'))
        ..initialize();
      _myTestProvider!.setPlayController(_videoPlayerController!);
      _myTestProvider!.setVideoStatus(VideoStatus.pause);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController!.value.isInitialized) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      }
      _videoPlayerController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return MouseRegion(
        onEnter: (_) {
          _myTestProvider!.setHideBlur(true);
        },
        onExit: (_) {
          _myTestProvider!.setHideBlur(false);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: provider.videoPlayController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(provider.videoPlayController),
                (provider.videoPlayController.value.isInitialized)
                    ? Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.all(10),
                        child: LinearProgressIndicator(
                          value: provider.videoPlayController.value.position
                                  .inSeconds /
                              provider
                                  .videoPlayController.value.duration.inSeconds,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.defaultPurpleColor),
                        ),
                      )
                    : Container(),
                _prepareCueCard(),
                _answerPlayholder(),
                _buildActionVideo()
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _prepareCueCard() {
    PlayListModel currentPlay = _myTestProvider!.currentPlay;
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return Visibility(
          visible: provider.showCueCard,
          child: Container(
            alignment: Alignment.center,
            color: AppColors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(currentPlay.questionContent,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(currentPlay.cueCard,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ));
    });
  }

  Widget _answerPlayholder() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return Visibility(
          visible: provider.showAnswerWave,
          child: SizedBox(
              width: w,
              height: h,
              child: const Image(
                image: AssetImage(
                  AppAssets.img_voice_line,
                ),
                fit: BoxFit.cover,
              )));
    });
  }

  Widget _buildActionVideo() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return (provider.hideBlur &&
              provider.videoPlayController.value.isInitialized)
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color.fromARGB(144, 129, 127, 127),
                ),
                (provider.videoStatus == VideoStatus.endVideo)
                    ? InkWell(
                        onTap: () {
                          //provider.videoPlayController.play();
                          provider.setVideoStatus(VideoStatus.playing);
                          _startVideoMyTest();
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
                          //provider.videoPlayController.play();
                          provider.setVideoStatus(VideoStatus.playing);
                          _startVideoMyTest();
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
                          provider.videoPlayController.pause();
                          provider.setVideoStatus(VideoStatus.pause);
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

/////////////////////// PLAY VIDEO MY TEST ACTION //////////////////////////////
  void _startVideoMyTest() {
    PlayListModel playModel = _myTestProvider!.playList.first;
    _playingVideoFile(playModel.fileIntro);
  }

  Future _playingVideo() async {
    int indexPlay = _myTestProvider!.indexCurrentPlay + 1;
    if (indexPlay <= _myTestProvider!.playList.length - 1) {
      _myTestProvider!.setIndexCurrentPlay(indexPlay);

      PlayListModel playListModel = _myTestProvider!.playList[indexPlay];

      String fileName = playListModel.fileIntro;
      if (playListModel.questionContent == PlayListType.introduce.name) {
        fileName = playListModel.fileIntro;
      } else if (playListModel.questionContent ==
          PlayListType.endOfTakeNote.name) {
        fileName = playListModel.endOfTakeNote;
      } else if (playListModel.questionContent == PlayListType.endOfTest.name) {
        fileName = playListModel.endOfTest;
      } else {
        fileName = playListModel.fileQuestionNormal;
      }
      _myTestProvider!.setCurrentPlay(playListModel);
      _playingVideoFile(fileName);
    } else {
      //_onEndTheTest();
    }
  }

  Future _playingVideoFile(String filePath) async {
    bool isExistFile =
        await FileStorageHelper.checkExistFile(filePath, MediaType.video, null);

    if (isExistFile) {
      String normalPath =
          await FileStorageHelper.getFilePath(filePath, MediaType.video, null);
      _initVideoController(File(normalPath));
    } else {
      //Handle have not file question
    }
  }

  Future _initVideoController(File file) async {
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((value) {
        _videoPlayerController!.value.isPlaying
            ? _videoPlayerController!.pause()
            : _videoPlayerController!.play();
        setState(() {});
      });

    // _videoPlayerController!.setPlaybackSpeed(_getSpeedVideo());

    _myTestProvider!.setPlayController(_videoPlayerController!);
    _myTestProvider!.videoPlayController.addListener(() {
      if (_myTestProvider!.videoPlayController.value.isPlaying) {
        _myTestProvider!.setVideoStatus(VideoStatus.playing);
      }
      if (_myTestProvider!.videoPlayController.value.position ==
          _myTestProvider!.videoPlayController.value.duration) {
        _onVideoEnd();
      }
    });
  }

  Future _onVideoEnd() async {
    if (!mounted) {
      return;
    }
    PlayListModel playListModel = _myTestProvider!.currentPlay;

    if (playListModel.questionContent == PlayListType.introduce.name) {
      _playingVideo();
    } else if (playListModel.cueCard.isNotEmpty) {
      _startShowCueCard();
    } else if (playListModel.questionContent == PlayListType.endOfTest.name ||
        _myTestProvider!.indexQuestion == _myTestProvider!.questionLength &&
            playListModel.numPart != PartOfTest.part2.get) {
      _stopMyTestVideo();
    } else {
      _playAnswer();
    }
  }

  void _startShowCueCard() {
    _myTestProvider!.setShowCueCard(true);
    _audioPlayer!.play(AssetSource(AppAssets.sound_default));
    Future.delayed(const Duration(seconds: 8), () {
      _myTestProvider!.setShowCueCard(false);
      _audioPlayer!.stop();
      _playingVideo();
    });
  }

  Future<void> _playAnswer() async {
    PlayListModel playListModel = _myTestProvider!.currentPlay;
    QuestionTopicModel currentQuestion = playListModel.questionTopicModel;
    List<FileTopicModel> answers = currentQuestion.answers;
    if (answers.isNotEmpty) {
      int indexAnswer = _myTestProvider!.repeatTimes;
      String fileName =
          Utils.instance().convertFileName(answers[indexAnswer].url);
      bool isExistFile = await FileStorageHelper.checkExistFile(
          fileName, MediaType.audio, null);

      if (isExistFile) {
        String audioPath = await FileStorageHelper.getFilePath(
            fileName, MediaType.audio, null);
        _myTestProvider!.setShowAnswerWave(true);
        _audioPlayer!.play(DeviceFileSource(audioPath));
        _audioPlayer!.onPlayerComplete.listen((event) {
          _onAnswerEnd(currentQuestion.answers);
        });
      } else {
        _playingVideo();
      }
    } else {
      _playingVideo();
    }
  }

  void _onAnswerEnd(List<FileTopicModel> answers) {
    int indexAnswer = _myTestProvider!.repeatTimes;
    if (answers.length > 1 && indexAnswer <= answers.length - 1) {
      _myTestProvider!.setRepeatTimes(indexAnswer + 1);
      if (kDebugMode) {
        print('DEBUG : index repeat : ${_myTestProvider!.repeatTimes}');
      }
      _myTestProvider!.setShowAnswerWave(false);
      _audioPlayer!.stop();
      PlayListModel playListModel = _myTestProvider!.currentPlay;
      _playingVideoFile(playListModel.fileQuestionNormal);
    } else {
      _myTestProvider!.setRepeatTimes(0);
      _myTestProvider!.setShowAnswerWave(false);
      _audioPlayer!.stop();
      _playingVideo();
    }
  }

  void _stopMyTestVideo() {
    _myTestProvider!.setVideoStatus(VideoStatus.endVideo);
    _myTestProvider!.setHideBlur(true);
  }

  double _getSpeedVideo() {
    PlayListModel playListModel = _myTestProvider!.currentPlay;
    switch (_myTestProvider!.repeatTimes) {
      case 1:
        return playListModel.firstRepeatSpeed;
      case 2:
        return playListModel.secondRepeatSpeed;
      default:
        return playListModel.normalSpeed;
    }
  }
}
