import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/presenters/test_room_presenter.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/widgets/empty_widget.dart';
import 'package:icorrect_pc/src/views/widgets/simulator_test_widgets/video_simulator_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../../../../core/app_assets.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
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
  Timer? _countDownCueCard;

  double w = 0;
  double h = 0;

  @override
  void initState() {
    super.initState();
    _roomProvider = Provider.of<TestRoomProvider>(context, listen: false);
    _presenter = TestRoomSimulatorPresenter(this);
    _prepareForTestRoom();
  }

  void _prepareForTestRoom() {
    Future.delayed(Duration.zero, () {
      _roomProvider!.clearData();
      Queue<TopicModel> topicsQueue = Queue<TopicModel>.from(
          _presenter!.getListTopicModel(widget.testDetailModel));
      TopicModel currentTopic = topicsQueue.first;
      _roomProvider!.setCurrentTopic(currentTopic);
      List<QuestionTopicModel> questionsOfCurrentTopic =
          _presenter!.getAllQuestionsTopic(currentTopic);
      _roomProvider!.setCurrentQuestionList(questionsOfCurrentTopic);

      topicsQueue.removeFirst();
      _roomProvider!.setTopicModelQueue(topicsQueue);
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
                    _onClickFinishAnswer();
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

  Widget _buildQuestionList() {
    return TestQuestionWidget(
        playAnswerCallBack: (question, index) {},
        playReAnswerCallBack: (question) {},
        showTipCallBack: (question) {});
  }

  void _onClickStartTest() {
    TopicModel currentTopic = _roomProvider!.currentTopic;
  //  _presenter!.doingTest(false, currentTopic);
  }

  @override
  void playIntroduce(File introduceFile) {
    _initVideoController(introduceFile);
  }

  @override
  void playQuestion(File normalFile, File slowFile) {
    _initVideoController(normalFile);
  }

  Future _initVideoController(File file) async {
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((value) {
        _videoPlayerController!.value.isPlaying
            ? _videoPlayerController!.pause()
            : _videoPlayerController!.play();
      });

    _roomProvider!.setPlayController(_videoPlayerController!);
  }

  Future _onVideoEnd() async {
    TopicModel currentTopic = _roomProvider!.currentTopic;
    _startCountDown(currentTopic.numPart, false);
    _roomProvider!.setVisibleRecord(true);
  }

  @override
  void onCountDown(String strCount) {
    _roomProvider!.setStrCountDown(strCount);
  }

  @override
  void onCountDownForCueCard(String strCount) {
    _roomProvider!.setStrCountCueCard(strCount);
  }

  void _onClickFinishAnswer() {}

  void _onClickRepeatAnswer() {}

  @override
  void onFinishAnswer(bool isPart2) {
    _roomProvider!.setVisibleRecord(false);
  }

  

  void _startCountDown(int numPart, bool hasCuecard) {
    if (null != _countDown) {
      _countDown!.cancel();
    }

    int countTime = Utils.instance().getRecordTime(numPart);
    if (hasCuecard) {
      _countDown = _presenter!.startCountDown(
          context: context, count: countTime, isPart2: hasCuecard);
    } else {
      _countDown = _presenter!.startCountDownForCueCard(
          context: context, count: countTime, isPart2: hasCuecard);
    }
  }
}
