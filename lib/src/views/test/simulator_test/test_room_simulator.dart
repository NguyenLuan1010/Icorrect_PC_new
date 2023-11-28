import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/core/camera_service.dart';
import 'package:icorrect_pc/core/compress_video.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/auth_models/video_record_exam_info.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/playlist_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/camera_preview_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/simulator_test_provider.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/dialogs/re_answer_dialog.dart';
import 'package:icorrect_pc/src/views/dialogs/tip_question_dialog.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';
import 'package:icorrect_pc/src/views/widgets/camera_preview.dart';
import 'package:icorrect_pc/src/views/widgets/empty_widget.dart';
import 'package:icorrect_pc/src/views/widgets/simulator_test_widgets/video_simulator_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:record/record.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/app_assets.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/simulator_test_models/file_topic_model.dart';
import '../../../models/simulator_test_models/test_detail_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../presenters/test_room_simulator_presenter.dart';
import '../../dialogs/message_alert.dart';
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
    with WindowListener
    implements TestRoomSimulatorContract {
  TestRoomProvider? _roomProvider;
  SimulatorTestProvider? _simulatorTestProvider;
  AuthWidgetProvider? _authWidgetProvider;
  CameraPreviewProvider? _cameraPreviewProvider;

  TestRoomSimulatorPresenter? _presenter;

  VideoPlayerController? _videoPlayerController;
  Timer? _countDown;
  AudioPlayer? _audioPlayer;
  Record? _recordController;
  String _fileNameRecord = '';
  CircleLoading? _loading;

  double w = 0;
  double h = 0;

  DateTime? _logStartTime;
  DateTime? _logEndTime;
  //type : 1 out app: play video  , 2 out app: record answer, 3 out app: takenote
  int _typeOfActionLog = 0; //Default

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _audioPlayer = AudioPlayer();
    _recordController = Record();
    _loading = CircleLoading();

    _roomProvider = Provider.of<TestRoomProvider>(context, listen: false);
    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _authWidgetProvider =
        Provider.of<AuthWidgetProvider>(context, listen: false);
    _presenter = TestRoomSimulatorPresenter(this);

    _prepareForTestRoom();
  }

  void _prepareForTestRoom() {
    Future.delayed(Duration.zero, () {
      _roomProvider!.clearData();
      List<PlayListModel> playLists =
          _presenter!.getPlayList(widget.testDetailModel);
      if (kDebugMode) {
        for (PlayListModel play in playLists) {
          print(
              "DEBUG : play list ${play.questionContent} ,cue card: ${play.cueCard}");
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
  void onWindowFocus() {
    if (kDebugMode) {
      print('DEBUG: Window on active');
    }
    _onWindowActive();
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    if (kDebugMode) {
      print('DEBUG: Window on pause');
    }
    _onWindowBlur();
  }

  Future _onWindowActive() async {
    //Calculation time of being out and save into a action log
    PlayListModel currentPlayList = _roomProvider!.currentPlay;
    if (null != _logStartTime &&
        currentPlayList.questionId != 0 &&
        widget.activitiesModel.isExam()) {
      _logEndTime = DateTime.now();
      if (kDebugMode) {
        print("DEBUG: action log endtime: $_logEndTime");
      }

      int second = Utils.instance()
          .getBeingOutTimeInSeconds(_logStartTime!, _logEndTime!);

      var jsonData = {
        "question_id": currentPlayList.questionId.toString(),
        "question_text": currentPlayList.questionContent,
        "type": _typeOfActionLog,
        "time": second
      };

      _resetActionLogTimes();

      //Add action log
      _simulatorTestProvider!.addLogActions(jsonData);
    }
  }

  Future _onWindowBlur() async {
    //Create start time to save log
    if (widget.activitiesModel.isExam()) {
      _logStartTime = DateTime.now();
      if (kDebugMode) {
        print("DEBUG: action log starttime: $_logStartTime");
      }

      if (_videoPlayerController != null) {
        bool isPlaying = _videoPlayerController!.value.isPlaying;
        if (isPlaying) {
          _typeOfActionLog = 1;
        }
      }

      if (_simulatorTestProvider!.visibleRecord) {
        _typeOfActionLog = 2;
      }
      if (null != _countDown && _simulatorTestProvider!.visibleCueCard) {
        _typeOfActionLog = 3;
      }
    }
  }

  void _resetActionLogTimes() {
    _logStartTime = null;
    _logEndTime = null;
  }

  @override
  void dispose() async {
    windowManager.removeListener(this);
    super.dispose();
    if (_countDown != null) {
      _countDown!.cancel();
    }

    if (_recordController != null && await _recordController!.isRecording()) {
      _recordController!.stop();
      _recordController!.dispose();
    }

    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
      _videoPlayerController!.dispose();
    }

    if (_audioPlayer != null) {
      _audioPlayer!.dispose();
    }
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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                widget.activitiesModel.isExam()
                    ? _buildQuestionAndCameraPreview()
                    : _buildQuestionList(),
                _buildImageFrame()
              ],
            ),
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
                SaveTheTestWidget(() {
                  _startSubmitAction();
                }),
                TestRecordWidget(
                  finishAnswer: (questionTopicModel) {
                    _onFinishAnswer();
                  },
                  repeatQuestion: (questionTopicModel) {
                    _onClickRepeatAnswer();
                  },
                ),
                const CueCardWidget(),
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
  Future<void> playFileVideo(File normalFile, File slowFile) async {
    PlayListModel playListModel = _roomProvider!.currentPlay;
    String path = await FileStorageHelper.getFilePath(
        playListModel.fileImage, MediaType.image, null);
    _roomProvider!.setFileImage(File(path));
    _initVideoController(normalFile);
  }

  Future _initVideoController(File file) async {
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((value) {
        _videoPlayerController!.value.isPlaying
            ? _videoPlayerController!.pause()
            : _videoPlayerController!.play();
        setState(() {});
      });

    _videoPlayerController!.setPlaybackSpeed(_getSpeedVideo());

    _roomProvider!.setPlayController(_videoPlayerController!);
    _roomProvider!.videoPlayController.addListener(() {
      if (_roomProvider!.videoPlayController.value.position ==
          _roomProvider!.videoPlayController.value.duration) {
        _onVideoEnd();
      }
    });
  }

  Future _onVideoEnd() async {
    if (!mounted) {
      return;
    }
    PlayListModel playListModel = _roomProvider!.currentPlay;

    if (playListModel.questionContent == PlayListType.introduce.name) {
      _doingTest();
    } else if (playListModel.cueCard.isNotEmpty) {
      _startCountDownCueCard();
    } else if (playListModel.questionContent == PlayListType.endOfTest.name ||
        _roomProvider!.indexQuestion == _roomProvider!.questionLength &&
            playListModel.numPart != PartOfTest.part2.get) {
      _onEndTheTest();
    } else {
      _startCountDownRecord();
    }
  }

  @override
  void onCountDown(String strCount, int count) {
    _roomProvider!.setStrCountDown(strCount);
    _roomProvider!.setCurrentCount(count);
  }

  @override
  void onCountDownForCueCard(String strCount) {
    _roomProvider!.setStrCountDown(strCount);
    _roomProvider!.setStrCountCueCard(strCount);
  }

  @override
  void onFinishAnswer(bool isPart2) {
    _onFinishAnswer();
  }

  Future<void> _onFinishAnswer() async {
    _roomProvider!.clearImageFile();
    _recordController!.stop();
    _roomProvider!.setVisibleRecord(false);
    CameraService.instance().stopRecording(
        cameraPreviewProvider: _cameraPreviewProvider!,
        savedVideoRecord: (savedFile) {
          int totalCount = Utils.instance().getRecordTime(_currentNumPart());
          int countTime = _roomProvider!.currentCount;

          _simulatorTestProvider!.addVideoRecorded(VideoExamRecordInfo(
              questionId: _roomProvider!.currentQuestion.id,
              filePath: savedFile.path,
              duration: totalCount - countTime));
        });
    PlayListModel playListModel = _roomProvider!.currentPlay;
    if (playListModel.questionTopicModel.id != 0) {
      playListModel.questionTopicModel.repeatIndex =
          playListModel.questionTopicModel.answers.isNotEmpty
              ? playListModel.questionTopicModel.answers.length - 1
              : 0;
      // _roomProvider!.addQuestionToList(playListModel.questionTopicModel);
      _simulatorTestProvider!
          .addQuestionToList(playListModel.questionTopicModel);
      _roomProvider!.setIndexQuestion(_roomProvider!.indexQuestion + 1);
    }
    _doingTest();
  }

  void _onClickRepeatAnswer() {
    _roomProvider!.setVisibleRecord(false);
    _roomProvider!.setRepeatTimes(_roomProvider!.repeatTimes + 1);
    PlayListModel playListModel = _roomProvider!.currentPlay;

    if (null != _countDown) {
      _countDown!.cancel();
    }

    QuestionTopicModel question = playListModel.questionTopicModel;
    QuestionTopicModel repeatQuestion = question.copyWith(
        id: question.id,
        content: "Ask for repeat question",
        type: question.type,
        topicId: question.topicId,
        tips: question.tips,
        tipType: question.tipType,
        isFollowUp: question.isFollowUp,
        cueCard: question.cueCard,
        reAnswerCount: question.reAnswerCount,
        answers: question.answers,
        numPart: question.numPart,
        repeatIndex: _roomProvider!.repeatTimes - 1,
        files: question.files);

    // _roomProvider!.questionList.add(repeatQuestion);
    _simulatorTestProvider!.questionList.add(repeatQuestion);

    _presenter!.playingQuestion(
        playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);
  }

  void _startCountDownRecord() {
    if (null != _countDown) {
      _countDown!.cancel();
    }
    _recordAnswer();

    _roomProvider!.setVisibleRecord(true);
    int countTime = _getCountTimeRecord();

    _countDown = _presenter!.startCountDown(
        context: context, count: countTime, isPart2: _isPart2());

    _roomProvider!.setCurrentCount(countTime);

    String timeFormat = Utils.instance().formattedTime(timeInSecond: countTime);
    _roomProvider!.setStrCountDown(timeFormat);

    CameraService.instance()
        .startRecording(cameraPreviewProvider: _cameraPreviewProvider!);
  }

  void _startCountDownCueCard() {
    if (null != _countDown) {
      _countDown!.cancel();
    }

    PlayListModel playListModel = _roomProvider!.currentPlay;
    _recordAnswer();
    String timeFormat = Utils.instance()
        .formattedTime(timeInSecond: playListModel.takeNoteTime);
    _roomProvider!.setStrCountDown(timeFormat);
    _countDown = _presenter!.startCountDownForCueCard(
        context: context,
        count: playListModel.takeNoteTime,
        isPart2: _isPart2());
    _roomProvider!.setCurrentCount(playListModel.takeNoteTime);
    _roomProvider!.setVisibleCueCard(true);
  }

  /////////////////////////////DOING TEST FUNCTION//////////////////////////////

  void _startDoingTest() {
    PlayListModel playModel = _roomProvider!.playList.first;
    _presenter!.playingIntroduce(playModel.fileIntro);
    _simulatorTestProvider!.updateDoingStatus(DoingStatus.doing);
  }

  void _doingTest() {
    int indexPlay = _roomProvider!.indexCurrentPlay + 1;
    if (indexPlay <= _roomProvider!.playList.length - 1) {
      _roomProvider!.setIndexCurrentPlay(indexPlay);

      if (kDebugMode) {
        PlayListModel playListModel1 = _roomProvider!.currentPlay;
        for (int i = 0;
            i < playListModel1.questionTopicModel.answers.length;
            i++) {
          print(
              "DEBUG : ${playListModel1.questionTopicModel.answers[i].url},index :${i.toString()}");
        }
      }
      PlayListModel playListModel = _roomProvider!.playList[indexPlay];

      _roomProvider!.setRepeatTimes(0);
      if (playListModel.questionContent == PlayListType.introduce.name) {
        _presenter!.playingIntroduce(playListModel.fileIntro);
      } else if (playListModel.questionContent ==
          PlayListType.endOfTakeNote.name) {
        _presenter!.playingEndOfTakeNote(playListModel.endOfTakeNote);
      } else if (playListModel.questionContent == PlayListType.endOfTest.name) {
        _presenter!.playingEndOfTest(playListModel.endOfTest);
      } else {
        _presenter!.playingQuestion(
            playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);
      }
      _roomProvider!.setCurrentPlay(playListModel);
    } else {
      _onEndTheTest();
    }
  }

  void _onEndTheTest() {
    //_simulatorTestProvider!.setQuestionList(_roomProvider!.questionList);
    _roomProvider!.setCanReanswer(!widget.activitiesModel.isExam());
    _roomProvider!.setCanPlayAnswer(true);
    _roomProvider!.setVisibleRecord(false);
    _simulatorTestProvider!.updateDoingStatus(DoingStatus.finish);

    if (null != _countDown) {
      _countDown!.cancel();
    }

    if (widget.activitiesModel.isExam()) {
      String pathVideo = _presenter!
          .randomVideoRecordExam(_simulatorTestProvider!.videosRecorded);
      if (kDebugMode) {
        print("RECORDING_VIDEO : Video Recording saved at: $pathVideo");
      }
      _submitExamAction(pathVideo);
    } else {
      _roomProvider!.setVisibleSaveTheTest(true);
    }
  }

  Future<void> _prepareVideoForSubmit() async {
    _loading!.show(context);
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);

    String pathVideo = _presenter!
        .randomVideoRecordExam(_simulatorTestProvider!.videosRecorded);
    if (kDebugMode) {
      print("RECORDING_VIDEO : Video Recording saved at: $pathVideo");
    }
    String outputPath =
        '${await FileStorageHelper.getFolderPath(MediaType.video, null)}'
        '\\VIDEO_EXAM_${DateTime.now().microsecond}.mp4';
    CompressVideo.instance().compressVideo(
        inputPath: pathVideo,
        outputPath: outputPath,
        onSuccess: () {
          _submitExamAction(outputPath);
        },
        onError: () {
          _submitExamAction(pathVideo);
        });
  }

  void _submitExamAction(String pathVideo) {
    _presenter!.submitMyTest(
        testId: widget.testDetailModel.testId.toString(),
        activityId: widget.activitiesModel.activityId.toString(),
        // questionsList: _roomProvider!.questionList,
        questionsList: _simulatorTestProvider!.questionList,
        isExam: widget.activitiesModel.isExam(),
        videoConfirmFile: File(pathVideo).existsSync() ? File(pathVideo) : null,
        logAction: _simulatorTestProvider!.logActions);
  }

  void _startSubmitAction() {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);
    _loading!.show(context);
    _presenter!.submitMyTest(
        testId: widget.testDetailModel.testId.toString(),
        activityId: widget.activitiesModel.activityId.toString(),
        questionsList: _simulatorTestProvider!.questionList,
        isExam: widget.activitiesModel.isExam());
  }

  Future<void> _recordAnswer() async {
    String newFileName =
        '${await Utils.instance().generateAudioFileName()}.wav';

    _fileNameRecord =
        await FileStorageHelper.getFilePath(newFileName, MediaType.audio, null);

    if (await _recordController!.hasPermission()) {
      await _recordController!.start(
        path: _fileNameRecord,
        encoder: Platform.isWindows ? AudioEncoder.wav : AudioEncoder.pcm16bit,
        bitRate: 128000,
        numChannels: 1,
        samplingRate: 44100,
      );
    }

    List<FileTopicModel> answers =
        _roomProvider!.currentPlay.questionTopicModel.answers;
    answers
        .add(FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
    _roomProvider!.currentPlay.questionTopicModel.answers = answers;
  }

  Widget _buildQuestionAndCameraPreview() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(50),
            child: CameraPreview(provider: _cameraPreviewProvider!),
          )),
      Expanded(flex: 3, child: _buildQuestionList()),
    ]);
  }

  Widget _buildQuestionList() {
    return Consumer<TestRoomProvider>(builder: (context, provider, child) {
      return TestQuestionWidget(
          isExam: widget.activitiesModel.isExam(),
          testId: widget.testDetailModel.testId,
          questions: _simulatorTestProvider!.questionList,
          canPlayAnswer: provider.canPlayAnswer,
          canReanswer: provider.canReanswer,
          isPlayingAnswer: provider.isPlaying,
          selectedQuestionIndex: provider.selectedQuestionIndex,
          playAnswerCallBack: _playAnswerCallBack,
          playReAnswerCallBack: _reanswerCallBack,
          showTipCallBack: (q) {
            _showTipQuestion(q);
          });
    });
  }

  void _showTipQuestion(QuestionTopicModel questionTopicModel) {
    showDialog(
        context: context,
        builder: (context) {
          return TipQuestionDialog(context, questionTopicModel);
        });
  }

  Widget _buildImageFrame() {
    return Consumer<TestRoomProvider>(builder: (context, provider, child) {
      return (provider.fileImage.existsSync())
          ? Container(
              width: w,
              padding: const EdgeInsets.all(40),
              color: Colors.white,
              child: Image.file(provider.fileImage),
            )
          : Container();
    });
  }

  Future _playAnswerCallBack(QuestionTopicModel question, int index) async {
    bool isPlaying = _roomProvider!.isPlaying;
    if (_roomProvider!.selectedQuestionIndex != index) {
      if (isPlaying) {
        await _audioPlayer!.stop();
        _roomProvider!.setSelectedQuestionIndex(index, false);
      }
      _startPlayAudio(question, index);
    } else {
      if (isPlaying) {
        await _audioPlayer!.stop();
        _roomProvider!.setSelectedQuestionIndex(index, false);
      } else {
        _startPlayAudio(question, index);
      }
    }
  }

  void _startPlayAudio(QuestionTopicModel question, int index) async {
    String path = await FileStorageHelper.getFilePath(
        question.answers[question.repeatIndex].url, MediaType.audio, null);
    try {
      await _audioPlayer!.play(DeviceFileSource(path));
      await _audioPlayer!.setVolume(2.5);
      _audioPlayer!.onPlayerComplete.listen((event) {
        _roomProvider!.setSelectedQuestionIndex(index, false);
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _roomProvider!.setSelectedQuestionIndex(index, true);
  }

  Future _reanswerCallBack(QuestionTopicModel question, int index) async {
    bool isPlaying = _roomProvider!.isPlaying;
    if (isPlaying) {
      await _audioPlayer!.stop();
      int indexQuestionPlaying = _roomProvider!.selectedQuestionIndex;
      _roomProvider!.setSelectedQuestionIndex(indexQuestionPlaying, false);
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ReAnswerDialog(
              context, question, widget.testDetailModel.testId.toString(),
              (question) {
            _simulatorTestProvider!.questionList[index] = question;
          });
        });
  }

  @override
  void submitAnswerFail(AlertInfo alertInfo) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });
  }

  @override
  void submitAnswersSuccess(AlertInfo alertInfo) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });

    if (mounted) {
      _authWidgetProvider!.setRefresh(true);
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
  ////////////////////////////CHECK VALUE FUNCTION//////////////////////////////

  int _getCountTimeRecord() {
    PlayListModel playListModel = _roomProvider!.currentPlay;
    int countTime = playListModel.part1Time;
    if (_isPart2()) {
      countTime = playListModel.part2Time;
    }
    if (_isPart3()) {
      countTime = playListModel.part3Time;
    }
    return countTime;
  }

  bool _isPart2() {
    return _roomProvider!.currentPlay != PlayListModel() &&
            _roomProvider!.currentPlay.cueCard.isNotEmpty ||
        _roomProvider!.currentPlay.numPart == PartOfTest.part2.get;
  }

  bool _isPart3() {
    return _roomProvider!.currentPlay.numPart == PartOfTest.part3.get;
  }

  int _currentNumPart() {
    if (_roomProvider!.currentPlay != PlayListModel()) {
      return _roomProvider!.currentPlay.numPart;
    }
    return -1;
  }

  double _getSpeedVideo() {
    PlayListModel playListModel = _roomProvider!.currentPlay;
    switch (_roomProvider!.repeatTimes) {
      case 1:
        return playListModel.firstRepeatSpeed;
      case 2:
        return playListModel.secondRepeatSpeed;
      default:
        return playListModel.normalSpeed;
    }
  }
}
