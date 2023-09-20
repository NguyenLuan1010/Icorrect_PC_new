import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/playlist_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/presenters/test_room_presenter.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/define_object.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/re_answer_dialog.dart';
import 'package:icorrect_pc/src/views/widgets/empty_widget.dart';
import 'package:icorrect_pc/src/views/widgets/simulator_test_widgets/video_simulator_widget.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../../../../core/app_assets.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/simulator_test_models/file_topic_model.dart';
import '../../../models/simulator_test_models/test_detail_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../presenters/test_room_simulator_presenter.dart';
import '../../widgets/simulator_test_widgets/cue_card_widget.dart';
import '../../widgets/simulator_test_widgets/save_test_widget.dart';
import '../../widgets/simulator_test_widgets/start_test_widget.dart';
import '../../widgets/simulator_test_widgets/test_question_widget.dart';
import '../../widgets/simulator_test_widgets/test_record_widget.dart';

class TestRoomSimulator extends StatefulWidget {
  final ActivitiesModel activitiesModel;
  final TestDetailModel testDetailModel;
  final SimulatorTestPresenter simulatorTestPresenter;
  const TestRoomSimulator(
      {super.key,
      required this.testDetailModel,
      required this.activitiesModel,
      required this.simulatorTestPresenter});

  @override
  State<TestRoomSimulator> createState() => _TestRoomSimulatorState();
}

class _TestRoomSimulatorState extends State<TestRoomSimulator>
    implements TestRoomSimulatorContract {
  TestRoomProvider? _roomProvider;
  TestRoomSimulatorPresenter? _presenter;

  VideoPlayerController? _videoPlayerController;
  Timer? _countDown;
  Record? _recordController;
  AudioPlayer? _audioPlayer;

  double w = 0;
  double h = 0;

  @override
  void initState() {
    super.initState();
    _recordController = Record();
    _audioPlayer = AudioPlayer();
    _roomProvider = Provider.of<TestRoomProvider>(context, listen: false);
    _presenter = TestRoomSimulatorPresenter(this);
    _prepareForTestRoom();
  }

  void _prepareForTestRoom() {
    Future.delayed(Duration.zero, () {
      _roomProvider!.clearData();
      List<PlayListModel> playLists =
          _presenter!.getPlayList(widget.testDetailModel);

      for (PlayListModel play in playLists) {
        if (kDebugMode) {
          print("DEBUG : play list ${play.questionContent}");
        }
      }

      _roomProvider!.setCanReanswer(false);
      _roomProvider!.setPlayList(playLists);
      _roomProvider!.setCurrentPlay(playLists.first);
      _roomProvider!.setQuestionLength(
          _presenter!.getQuestionLength(widget.testDetailModel));
    });
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return _buildTestRoom();
  }

  Widget _buildTestRoom() {
    return Container(
      width: w,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Container(
            width: w,
            height: h / 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildSimulatorVideo(),
          ),
          Container(
            width: w,
            height: h / 2,
            child: _buildQuestionList(),
          )
        ],
      ),
    );
  }

  Widget _buildSimulatorVideo() {
    return Container(
      width: w,
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.black, width: 2),
          image: const DecorationImage(
              image: AssetImage(AppAssets.bg_test_room), fit: BoxFit.cover)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: w / 3,
            child: VideoSimulatorWidget(
                roomProvider: _roomProvider!,
                onVideoEnd: () {
                  _onVideoEnd();
                }),
          ),
          Container(
            width: w / 2,
            alignment: Alignment.center,
            child: Stack(
              children: [
                StartTestWidget(onClickStartTest: () {
                  _onClickStartTest();
                }),
                SaveTheTestWidget(),
                TestRecordWidget(
                  finishAnswer: (questionTopicModel) {
                    _onFinishAnswer();
                  },
                  repeatQuestion: (questionTopicModel) {
                    _onClickRepeatAnswer();
                  },
                ),
                CueCardWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onClickStartTest() {
    _startDoingTest();
  }

  @override
  void playIntroduce(File introduceFile) {
    _initVideoController(introduceFile);
  }

  @override
  void playQuestion(File normalFile, File slowFile) {
    if (_roomProvider!.repeatTimes >= 1) {
      File videoFile = normalFile;
      if (normalFile.path != slowFile.path) {
        videoFile = slowFile;
      } else {
        _videoPlayerController!.setPlaybackSpeed(0.7);
      }
      
    } else {}
  }

  @override
  void playEndOfTakeNote(File endOfTakeNoteFile) {
    _initVideoController(endOfTakeNoteFile);
  }

  @override
  void playEndOfTest(File fileEndOfTest) {
    _initVideoController(fileEndOfTest);
  }

  Future _initVideoController(File file) async {
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((value) {
        _videoPlayerController!.value.isPlaying
            ? _videoPlayerController!.pause()
            : _videoPlayerController!.play();
      });

    _roomProvider!.setPlayController(_videoPlayerController!);
    _roomProvider!.videoPlayController.addListener(() {
      if (_roomProvider!.videoPlayController.value.position ==
          _roomProvider!.videoPlayController.value.duration) {
        _onVideoEnd();
      }
    });
  }

  Future _onVideoEnd() async {
    PlayListModel playListModel = _roomProvider!.currentPlay;

    if (playListModel.questionContent == PlayListType.introduce.name) {
      _doingTest();
    } else if (playListModel.cueCard.isNotEmpty) {
      _startCountDownCueCard();
    } else if (playListModel.questionContent == PlayListType.endOfTest.name ||
        _roomProvider!.indexQuestion == _roomProvider!.questionLength) {
      _roomProvider!.setVisibleSaveTheTest(true);
      _roomProvider!
          .setCanReanswer(widget.activitiesModel.activityType == "homework");
      _roomProvider!.setCanPlayAnswer(true);
      _roomProvider!.setVisibleRecord(false);
      if (null != _countDown) {
        _countDown!.cancel();
      }
    } else {
      _startCountDownRecord();
    }
  }

  @override
  void onCountDown(String strCount) {
    _roomProvider!.setStrCountDown(strCount);
  }

  @override
  void onCountDownForCueCard(String strCount) {
    _roomProvider!.setStrCountCueCard(strCount);
  }

  @override
  void onFinishAnswer(bool isPart2) {
    _onFinishAnswer();
  }

  Future<void> _onFinishAnswer() async {
    _recordController!.stop();
    _roomProvider!.setVisibleRecord(false);
    PlayListModel playListModel = _roomProvider!.currentPlay;
    if (playListModel.questionTopicModel.id != 0) {
      _roomProvider!.addQuestionToList(playListModel.questionTopicModel);
      _roomProvider!.setIndexQuestion(_roomProvider!.indexQuestion + 1);
    }
    _doingTest();
  }

  // Future<String> _fileDuration(String path) async {
  //   _audioPlayer!.setSourceUrl("https://icorrect-audio.s3.ap-southeast-1.amazonaws.com/audio/1680050829_5506-0.mp3");
  //   return await _audioPlayer!.getDuration().then((value) {
  //     return Utils.instance().formatDuration(value!);
  //   });
  // }

  void _onClickRepeatAnswer() {
    _roomProvider!.setRepeatTimes(_roomProvider!.repeatTimes + 1);
    PlayListModel playListModel = _roomProvider!.currentPlay;

    if (null != _countDown) {
      _countDown!.cancel();
    }

    _roomProvider!.setVisibleRecord(false);

    _presenter!.playingQuestion(
        playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);
  }

  void _startCountDownRecord() {
    if (null != _countDown) {
      _countDown!.cancel();
    }

    _recordAnswer();

    int countTime = Utils.instance().getRecordTime(_currentNumPart());
    _countDown = _presenter!.startCountDown(
        context: context, count: countTime, isPart2: _isPart2());
    _roomProvider!.setVisibleRecord(true);
    _roomProvider!.setStrCountDown("00:$countTime");
  }

  void _startCountDownCueCard() {
    if (null != _countDown) {
      _countDown!.cancel();
    }
    _recordAnswer();
    int countTime = Utils.instance().getRecordTime(_currentNumPart());
    _roomProvider!.setStrCountDown("00:$countTime");
    _countDown = _presenter!.startCountDownForCueCard(
        context: context, count: 5, isPart2: _isPart2());
    _roomProvider!.setVisibleCueCard(true);
  }

  /////////////////////////////DOING TEST FUNCTION//////////////////////////////

  void _startDoingTest() {
    PlayListModel playModel = _roomProvider!.playList.first;
    _presenter!.playingIntroduce(playModel.fileIntro);
  }

  void _doingTest() {
    int indexPlay = _roomProvider!.indexCurrentPlay + 1;
    _roomProvider!.setIndexCurrentPlay(indexPlay);
    PlayListModel playListModel1 = _roomProvider!.currentPlay;
    for (int i = 0; i < playListModel1.questionTopicModel.answers.length; i++) {
      if (kDebugMode) {
        print(
            "DEBUG : ${playListModel1.questionTopicModel.answers[i].url},index :${i.toString()}");
      }
    }
    PlayListModel playListModel = _roomProvider!.playList[indexPlay];

    if (playListModel.questionContent == PlayListType.introduce.name) {
      _presenter!.playingIntroduce(playListModel.fileIntro);
    } else if (playListModel.questionContent ==
        PlayListType.endOfTakeNote.name) {
      _presenter!.playingEndOfTakeNote(playListModel.endOfTakeNote);
    } else if (playListModel.questionContent == PlayListType.endOfTest.name) {
      _presenter!.playingEndOfTest(playListModel.endOfTest);
    } else {
      _roomProvider!.setRepeatTimes(0);
      _presenter!.playingQuestion(
          playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);
    }
    _roomProvider!.setCurrentPlay(playListModel);
  }

  Future<void> _recordAnswer() async {
    String newFileName =
        '${await Utils.instance().generateAudioFileName()}.wav';
    String path = await FileStorageHelper.getFilePath(
        newFileName, MediaType.audio, widget.testDetailModel.testId.toString());

    if (await _recordController!.hasPermission()) {
      await _recordController!.start(
        path: path,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }

    List<FileTopicModel> answers =
        _roomProvider!.currentPlay.questionTopicModel.answers;
    answers
        .add(FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
    _roomProvider!.currentPlay.questionTopicModel.answers = answers;
  }

  Widget _buildQuestionList() {
    return TestQuestionWidget(
        testId: widget.testDetailModel.testId,
        playAnswerCallBack: _playAnswerCallBack,
        playReAnswerCallBack: _reanswerCallBack,
        showTipCallBack: (q) {});
  }

  Future _playAnswerCallBack(QuestionTopicModel question, int index) async {
    bool isPlaying = _roomProvider!.isPlaying;
    if (isPlaying) {
      await _audioPlayer!.stop();
      _roomProvider!.setSelectedQuestionIndex(index, false);
    } else {
      String path = await FileStorageHelper.getFilePath(
          question.answers.last.url,
          MediaType.audio,
          widget.testDetailModel.testId.toString());

      try {
        await _audioPlayer!.play(DeviceFileSource(path));
        await _audioPlayer!.setVolume(2.5);
        _audioPlayer!.onPlayerComplete.listen((event) {
          _roomProvider!.setSelectedQuestionIndex(index, false);
        });
      } on PlatformException catch (e) {
        print(e);
      }
      _roomProvider!.setSelectedQuestionIndex(index, true);
    }
  }

  Future _reanswerCallBack(QuestionTopicModel question) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ReAnswerDialog(context, question,
              widget.testDetailModel.testId.toString(), (question) {});
        });
  }

  ////////////////////////////CHECK VALUE FUNCTION//////////////////////////////

  bool _isPart2() {
    return _roomProvider!.currentPlay != PlayListModel() &&
        _roomProvider!.currentPlay.cueCard.isNotEmpty;
  }

  int _currentNumPart() {
    if (_roomProvider!.currentPlay != PlayListModel()) {
      return _roomProvider!.currentPlay.numPart;
    }
    return -1;
  }
}
