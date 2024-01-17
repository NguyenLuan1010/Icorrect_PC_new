import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as AudioPlayers;
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
import '../../../models/log_models/log_model.dart';
import '../../../models/simulator_test_models/file_topic_model.dart';
import '../../../models/simulator_test_models/test_detail_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../presenters/test_room_simulator_presenter.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/simulator_test_widgets/cue_card_widget.dart';
import '../../widgets/simulator_test_widgets/save_test_widget.dart';
import '../../widgets/simulator_test_widgets/start_test_widget.dart';
import '../../widgets/simulator_test_widgets/test_question_widget.dart';
import '../../widgets/simulator_test_widgets/test_record_widget.dart';

class TestRoomSimulator extends StatefulWidget {
  final ActivitiesModel? activitiesModel;
  final TestDetailModel testDetailModel;
  final SimulatorTestPresenter simulatorTestPresenter;
  final SimulatorTestProvider simulatorTestProvider;
  const TestRoomSimulator(
      {super.key,
      required this.testDetailModel,
      this.activitiesModel,
      required this.simulatorTestPresenter,
      required this.simulatorTestProvider});

  @override
  State<TestRoomSimulator> createState() => _TestRoomSimulatorState();
}

class _TestRoomSimulatorState extends State<TestRoomSimulator>
    with WindowListener, AutomaticKeepAliveClientMixin<TestRoomSimulator>
    implements TestRoomSimulatorContract {
  CameraPreviewProvider? _cameraPreviewProvider;

  TestRoomSimulatorPresenter? _presenter;

  VideoPlayerController? _videoPlayerController;
  Timer? _countDown;
  AudioPlayers.AudioPlayer? _audioPlayer;
  Record? _recordController;
  String _fileNameRecord = '';
  CircleLoading? _loading;

  double w = 0;
  double h = 0;

  DateTime? _logStartTime;
  DateTime? _logEndTime;

  bool _isExam = false;
  bool _dialogNotShowing = true;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _audioPlayer = AudioPlayers.AudioPlayer();
    _recordController = Record();
    _loading = CircleLoading();

    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);
    _presenter = TestRoomSimulatorPresenter(this);

    if (widget.activitiesModel != null) {
      _isExam =
          widget.activitiesModel!.activityType == ActivityType.exam.name ||
              widget.activitiesModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }

    _prepareForTestRoom();
  }

  void _prepareForTestRoom() {
    Future.delayed(Duration.zero, () {
      List<PlayListModel> playLists =
          _presenter!.getPlayList(widget.testDetailModel);
      if (kDebugMode) {
        for (PlayListModel play in playLists) {
          print(
              "DEBUG : play list ${play.questionContent} ,cue card: ${play.cueCard}");
        }
      }

      if (widget.simulatorTestProvider.submitStatus != SubmitStatus.success) {
        if (!widget.simulatorTestProvider.isDownloadAgain &&
            widget.simulatorTestProvider.doingStatus != DoingStatus.doing) {
          widget.simulatorTestProvider.setVisibleSaveTheTest(false);
          widget.simulatorTestProvider.setStartTest(false);
        }
        widget.simulatorTestProvider.setCanReanswer(false);
        widget.simulatorTestProvider.setPlayList(playLists);
        if (widget.simulatorTestProvider.reanswersList.isNotEmpty) {
          widget.simulatorTestProvider.setVisibleSaveTheTest(false);
          widget.simulatorTestProvider.clearReasnwersList();
        }
        widget.simulatorTestProvider.setCurrentPlay(playLists.first);
        widget.simulatorTestProvider.setQuestionLength(
            _presenter!.getQuestionLength(widget.testDetailModel));
      }
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
    _onOutStateWhenTesting();
  }

  @override
  void onWindowUnmaximize() {
    _onOutStateWhenTesting();
  }

  Future _onWindowActive() async {
    //Calculation time of being out and save into a action log
    PlayListModel currentPlayList = widget.simulatorTestProvider.currentPlay;
    if (null != _logStartTime && _isExam) {
      _logEndTime = DateTime.now();
      if (kDebugMode) {
        print("DEBUG: action log endtime: $_logEndTime");
      }
      int second = Utils.instance()
          .getBeingOutTimeInSeconds(_logStartTime!, _logEndTime!);

      var jsonData = {
        "question_id": currentPlayList.questionId.toString(),
        "question_text": currentPlayList.questionContent,
        "type": widget.simulatorTestProvider.typeOfActionLog,
        "time": second
      };

      //Add action log
      widget.simulatorTestProvider.addLogActions(jsonData);
      _resetActionLogTimes();
    }
  }

  void _onOutStateWhenTesting() {
    if (_isExam) {
      _logStartTime = DateTime.now();
      if (kDebugMode) {
        print("DEBUG: action log starttime: $_logStartTime");
      }

      if (_videoPlayerController != null) {
        bool isPlaying = _videoPlayerController!.value.isPlaying;
        if (isPlaying) {
          widget.simulatorTestProvider.setTypeOfActionLog(1);
        }
      }

      if (widget.simulatorTestProvider.visibleRecord) {
        widget.simulatorTestProvider.setTypeOfActionLog(2);
      }
      if (null != _countDown && widget.simulatorTestProvider.isVisibleCueCard) {
        widget.simulatorTestProvider.setTypeOfActionLog(3);
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
    super.build(context);
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      if (provider.isDownloadAgainSuccess &&
          provider.doingStatus == DoingStatus.doing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onDownloadAgainCompleted();
        });
      }
      return (w < SizeLayout.MyTestScreenSize)
          ? _buildTestRoomTabletLayout()
          : _buildTestRoomDesktopLayout();
    });
  }

  Widget _buildTestRoomDesktopLayout() {
    return SizedBox(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: w,
            height: h / 2.5,
            child: _buildSimulatorVideo(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: w,
              height: h / 2.5,
              child: Stack(
                children: [
                  // widget.activitiesModel.isExam()
                  //     ? _buildQuestionAndCameraPreview()
                  //     : _buildQuestionList(),
                  _buildQuestionList(),
                  _buildImageFrame()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTestRoomTabletLayout() {
    return SizedBox(
        width: w,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: w,
                  height: h / 2,
                  child: Container(
                    width: w,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.black, width: 2),
                        image: const DecorationImage(
                            image: AssetImage(AppAssets.bg_test_room),
                            fit: BoxFit.cover)),
                    child: SizedBox(
                      width: w / 3,
                      child: VideoSimulatorWidget(onVideoEnd: () {
                        _onVideoEnd();
                      }),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: w,
                    height: h / 2.5,
                    child: Stack(
                      children: [
                        // widget.activitiesModel.isExam()
                        //     ? _buildQuestionAndCameraPreview()
                        //     : _buildQuestionList(),
                        _buildQuestionList(),
                        _buildImageFrame()
                      ],
                    ),
                  ),
                )
              ],
            ),
            if (widget.simulatorTestProvider.submitStatus !=
                SubmitStatus.success)
              Card(
                elevation: 3,
                child: Container(
                  width: w,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.bottomCenter,
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
                        simulatorTestProvider: widget.simulatorTestProvider,
                      ),
                      const CueCardWidget(),
                    ],
                  ),
                ),
              )
          ],
        ));
  }

  Widget _buildSimulatorVideo() {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
            child: VideoSimulatorWidget(onVideoEnd: () {
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
                  simulatorTestProvider: widget.simulatorTestProvider,
                ),
                const CueCardWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _createLog(
      {required String action, required Map<String, dynamic>? data}) async {
    if (context.mounted) {
      //Add action log
      LogModel actionLog =
          await Utils.instance().prepareToCreateLog(context, action: action);
      if (null != data) {
        if (data.isNotEmpty) {
          actionLog.addData(
              key: StringConstants.k_data, value: jsonEncode(data));
        }
      }
      Utils.instance().addLog(actionLog, LogEvent.none);
    }
  }

  void _onClickStartTest() {
    Map<String, dynamic> info = {
      StringConstants.k_test_id:
          widget.simulatorTestProvider.currentTestDetail.testId.toString(),
    };
    if (widget.activitiesModel != null) {
      info.addEntries([
        MapEntry(StringConstants.k_activity_id,
            widget.activitiesModel!.activityId.toString())
      ]);
    }
    _createLog(action: LogEvent.actionStartToDoTest, data: info);
    _startDoingTest();
  }

  @override
  Future<void> playFileVideo(File normalFile, File slowFile) async {
    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;
    String path = await FileStorageHelper.getFilePath(
        playListModel.fileImage, MediaType.image, null);
    widget.simulatorTestProvider.setFileImage(File(path));
    _initVideoController(normalFile);
  }

  Future _initVideoController(File file) async {
    if (kDebugMode) {
      print("DEBUG: File video : ${file.path}");
    }
    _videoPlayerController = VideoPlayerController.file(file);

    _videoPlayerController!.setPlaybackSpeed(_getSpeedVideo());
    _videoPlayerController!.initialize().then((value) {
      _videoPlayerController!.value.isPlaying
          ? _videoPlayerController!.pause()
          : _videoPlayerController!.play();
      setState(() {});
    });

    //   Map<String, dynamic> info = {
    //   StringConstants.k_file_id: file.id.toString(),
    //   StringConstants.k_file_url: file.path,
    // };
    // _createLog(action: LogEvent.actionPlayVideoQuestion, data: info)

    widget.simulatorTestProvider.setPlayController(_videoPlayerController!);
    widget.simulatorTestProvider.videoPlayController.addListener(() {
      if (widget.simulatorTestProvider.videoPlayController.value.position ==
          widget.simulatorTestProvider.videoPlayController.value.duration) {
        _onVideoEnd();
      }
    });
  }

  Future _onVideoEnd() async {
    if (!mounted) {
      return;
    }
    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;

    if (playListModel.questionContent == PlayListType.introduce.name) {
      _doingTest();
    } else if (playListModel.cueCard.isNotEmpty) {
      _startCountDownCueCard();
    } else if (playListModel.questionContent == PlayListType.endOfTest.name ||
        widget.simulatorTestProvider.indexQuestion ==
                widget.simulatorTestProvider.questionLength &&
            playListModel.numPart != PartOfTest.part2.get) {
      _onEndTheTest();
    } else {
      _startCountDownRecord();
    }
  }

  @override
  void onCountDown(String strCount, int count) {
    widget.simulatorTestProvider.setStrCountDown(strCount);
    widget.simulatorTestProvider.setCurrentCount(count);
  }

  @override
  void onCountDownForCueCard(String strCount) {
    widget.simulatorTestProvider.setStrCountDown(strCount);
    widget.simulatorTestProvider.setStrCountCueCard(strCount);
  }

  @override
  void onFileNotFound() {
    _showCheckNetworkDialog();
  }

  void _showCheckNetworkDialog() async {
    if (_dialogNotShowing) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title:
                Utils.instance().multiLanguage(StringConstants.warning_title),
            description: Utils.instance()
                .multiLanguage(StringConstants.video_not_found_message),
            okButtonTitle: StringConstants.ok_button_title,
            cancelButtonTitle: Utils.instance()
                .multiLanguage(StringConstants.exit_button_title),
            borderRadius: 8,
            hasCloseButton: false,
            okButtonTapped: () {
              _dialogNotShowing = true;
              Utils.instance().checkInternetConnection().then((isConnected) {
                if (isConnected) {
                  widget.simulatorTestPresenter.tryAgainToDownload();
                } else {
                  _showCheckNetworkDialog();
                }
              });
            },
            cancelButtonTapped: () {
              _dialogNotShowing = true;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        },
      );
      _dialogNotShowing = false;
    }
  }

  void _onDownloadAgainCompleted() {
    widget.simulatorTestProvider.setVisibleRecord(false);
    widget.simulatorTestProvider.setVisibleCueCard(false);
    if (null != _countDown) {
      _countDown!.cancel();
    }
    // PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;

    // _presenter!.playingQuestion(
    //     playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);

    int indexPlay = widget.simulatorTestProvider.indexCurrentPlay;
    widget.simulatorTestProvider.setIndexCurrentPlay(indexPlay);

    PlayListModel playListModel =
        widget.simulatorTestProvider.playList[indexPlay];

    widget.simulatorTestProvider.setRepeatTimes(0);
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
    widget.simulatorTestProvider.setCurrentPlay(playListModel);

    widget.simulatorTestProvider.setDownloadAgain(false);
    widget.simulatorTestProvider.setDownloadAgainSuccess(false);
  }

  @override
  void onFinishAnswer(bool isPart2) {
    _onFinishAnswer();
  }

  Future<void> _onFinishAnswer() async {
    if (_isExam) {
      _callTestPositionApi();
    }
    widget.simulatorTestProvider.clearImageFile();
    _recordController!.stop();
    widget.simulatorTestProvider.setVisibleRecord(false);
    // CameraService.instance().stopRecording(
    //     cameraPreviewProvider: _cameraPreviewProvider!,
    //     savedVideoRecord: (savedFile) {
    //       int totalCount = Utils.instance().getRecordTime(_currentNumPart());
    //       int countTime = widget.simulatorTestProvider.currentCount;

    //       widget.simulatorTestProvider.addVideoRecorded(VideoExamRecordInfo(
    //           questionId: widget.simulatorTestProvider.currentQuestion.id,
    //           filePath: savedFile.path,
    //           duration: totalCount - countTime));
    //     });

    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;
    if (playListModel.questionTopicModel.id != 0) {
      Map<String, dynamic> info = {
        StringConstants.k_question_id:
            playListModel.questionTopicModel.id.toString(),
        StringConstants.k_question_content:
            playListModel.questionTopicModel.content,
      };
      _createLog(action: LogEvent.actionFinishAnswer, data: info);

      playListModel.questionTopicModel.repeatIndex =
          playListModel.questionTopicModel.answers.isNotEmpty
              ? playListModel.questionTopicModel.answers.length - 1
              : 0;
      // widget.simulatorTestProvider.addQuestionToList(playListModel.questionTopicModel);
      widget.simulatorTestProvider
          .addQuestionToList(playListModel.questionTopicModel);
      widget.simulatorTestProvider
          .setIndexQuestion(widget.simulatorTestProvider.indexQuestion + 1);
    }
    _doingTest();
  }

  void _callTestPositionApi() {
    if (widget.activitiesModel != null) {
      String activityId = widget.activitiesModel!.activityId.toString();
      _presenter!.callTestPositionApi(
        context,
        activityId: activityId,
        questionIndex: widget.simulatorTestProvider.indexQuestion,
      );
    }
  }

  void _onClickRepeatAnswer() {
    widget.simulatorTestProvider.setVisibleRecord(false);
    widget.simulatorTestProvider
        .setRepeatTimes(widget.simulatorTestProvider.repeatTimes + 1);
    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;

    if (null != _countDown) {
      _countDown!.cancel();
    }

    QuestionTopicModel question = playListModel.questionTopicModel;
    Map<String, dynamic> info = {
      StringConstants.k_question_id: question.id.toString(),
      StringConstants.k_question_content: question.content,
    };
    _createLog(action: LogEvent.actionRepeatQuestion, data: info);

    QuestionTopicModel repeatQuestion = question.copyWith(
        id: question.id,
        content: Utils.instance()
            .multiLanguage(StringConstants.ask_for_question_title),
        type: question.type,
        topicId: question.topicId,
        tips: question.tips,
        tipType: question.tipType,
        isFollowUp: question.isFollowUp,
        cueCard: question.cueCard,
        reAnswerCount: question.reAnswerCount,
        answers: question.answers,
        numPart: question.numPart,
        repeatIndex: widget.simulatorTestProvider.repeatTimes - 1,
        files: question.files);

    // widget.simulatorTestProvider.questionList.add(repeatQuestion);
    widget.simulatorTestProvider.questionList.add(repeatQuestion);

    Future.delayed(const Duration(milliseconds: 500), () {
      _presenter!.playingQuestion(
          playListModel.fileQuestionNormal, playListModel.fileQuestionSlow);
    });
  }

  void _startCountDownRecord() {
    if (null != _countDown) {
      _countDown!.cancel();
    }
    _recordAnswer();

    widget.simulatorTestProvider.setVisibleRecord(true);
    int countTime = _getCountTimeRecord();

    _countDown = _presenter!.startCountDown(
        context: context, count: countTime, isPart2: _isPart2());

    widget.simulatorTestProvider.setCurrentCount(countTime);

    String timeFormat = Utils.instance().formattedTime(timeInSecond: countTime);
    widget.simulatorTestProvider.setStrCountDown(timeFormat);

    // CameraService.instance()
    //     .startRecording(cameraPreviewProvider: _cameraPreviewProvider!);
  }

  void _startCountDownCueCard() {
    if (null != _countDown) {
      _countDown!.cancel();
    }

    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;
    _recordAnswer();
    String timeFormat = Utils.instance()
        .formattedTime(timeInSecond: playListModel.takeNoteTime);
    widget.simulatorTestProvider.setStrCountDown(timeFormat);
    _countDown = _presenter!.startCountDownForCueCard(
        context: context,
        count: playListModel.takeNoteTime,
        isPart2: _isPart2());
    widget.simulatorTestProvider.setCurrentCount(playListModel.takeNoteTime);
    widget.simulatorTestProvider.setVisibleCueCard(true);
  }

  /////////////////////////////DOING TEST FUNCTION//////////////////////////////

  void _startDoingTest() {
    PlayListModel playModel = widget.simulatorTestProvider.playList.first;
    _presenter!.playingIntroduce(playModel.fileIntro);

    widget.simulatorTestProvider.updateDoingStatus(DoingStatus.doing);
  }

  void _doingTest() {
    int indexPlay = widget.simulatorTestProvider.indexCurrentPlay + 1;
    if (indexPlay <= widget.simulatorTestProvider.playList.length - 1) {
      widget.simulatorTestProvider.setIndexCurrentPlay(indexPlay);

      if (kDebugMode) {
        PlayListModel playListModel1 = widget.simulatorTestProvider.currentPlay;
        for (int i = 0;
            i < playListModel1.questionTopicModel.answers.length;
            i++) {
          print(
              "DEBUG : ${playListModel1.questionTopicModel.answers[i].url},index :${i.toString()}");
        }
      }
      PlayListModel playListModel =
          widget.simulatorTestProvider.playList[indexPlay];

      widget.simulatorTestProvider.setRepeatTimes(0);
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
      widget.simulatorTestProvider.setCurrentPlay(playListModel);
    } else {
      _onEndTheTest();
    }
  }

  void _onEndTheTest() {
    //widget.simulatorTestProvider.setQuestionList(widget.simulatorTestProvider.questionList);
    widget.simulatorTestProvider.setCanReanswer(!_isExam);
    widget.simulatorTestProvider.setCanPlayAnswer(true);
    widget.simulatorTestProvider.setVisibleRecord(false);
    widget.simulatorTestProvider.updateDoingStatus(DoingStatus.finish);

    if (null != _countDown) {
      _countDown!.cancel();
    }

    if (_isExam) {
      String pathVideo = _presenter!
          .randomVideoRecordExam(widget.simulatorTestProvider.videosRecorded);
      if (kDebugMode) {
        print("RECORDING_VIDEO : Video Recording saved at: $pathVideo");
      }
      _submitExamAction(pathVideo);
    } else {
      widget.simulatorTestProvider.setVisibleSaveTheTest(true);
    }
  }

  Future<void> _prepareVideoForSubmit() async {
    _loading!.show(context);
    widget.simulatorTestProvider.updateSubmitStatus(SubmitStatus.submitting);

    String pathVideo = _presenter!
        .randomVideoRecordExam(widget.simulatorTestProvider.videosRecorded);
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
    Utils.instance().checkInternetConnection().then((isConnected) {
      if (isConnected) {
        widget.simulatorTestProvider
            .updateSubmitStatus(SubmitStatus.submitting);
        _loading!.show(context);

        String activityId = "";
        if (widget.activitiesModel != null) {
          activityId = widget.activitiesModel!.activityId.toString();
        }

        _presenter!.submitMyTest(
            context: context,
            testId: widget.testDetailModel.testId.toString(),
            activityId: activityId,
            // questionsList: widget.simulatorTestProvider.questionList,
            questionsList: widget.simulatorTestProvider.questionList,
            isExam: _isExam,
            isUpdate: false,
            videoConfirmFile:
                File(pathVideo).existsSync() ? File(pathVideo) : null,
            logAction: widget.simulatorTestProvider.logActions);
      } else {
        if (kDebugMode) {
          print("DEBUG: Connect error here!");
        }
        Utils.instance().showConnectionErrorDialog(context);

        Utils.instance().addConnectionErrorLog(context);
      }
    });
  }

  void _startSubmitAction() {
    Utils.instance().checkInternetConnection().then((isConnected) {
      if (isConnected) {
        _loading!.show(context);
        String activityId = "";
        if (widget.activitiesModel != null) {
          activityId = widget.activitiesModel!.activityId.toString();
        }
        if (widget.simulatorTestProvider.reanswersList.isNotEmpty) {
          _presenter!.submitMyTest(
              context: context,
              testId: widget.testDetailModel.testId.toString(),
              activityId: activityId,
              questionsList: widget.simulatorTestProvider.reanswersList,
              isUpdate: true,
              isExam: _isExam);
        } else {
          _presenter!.submitMyTest(
              context: context,
              testId: widget.testDetailModel.testId.toString(),
              activityId: activityId,
              questionsList: widget.simulatorTestProvider.questionList,
              isUpdate: false,
              isExam: _isExam);
          widget.simulatorTestProvider
              .updateSubmitStatus(SubmitStatus.submitting);
        }
      } else {
        if (kDebugMode) {
          print("DEBUG: Connect error here!");
        }
        Utils.instance().showConnectionErrorDialog(context);

        Utils.instance().addConnectionErrorLog(context);
      }
    });
  }

  Future<void> _recordAnswer() async {
    try {
      String newFileName =
          '${await Utils.instance().generateAudioFileName()}.wav';

      _fileNameRecord = await FileStorageHelper.getFilePath(
          newFileName, MediaType.audio, null);

      if (await _recordController!.hasPermission()) {
        await _recordController!.start(
          path: _fileNameRecord,
          encoder:
              Platform.isWindows ? AudioEncoder.wav : AudioEncoder.pcm16bit,
          bitRate: 128000,
          numChannels: 1,
          samplingRate: 44100,
        );
      }

      List<FileTopicModel> answers =
          widget.simulatorTestProvider.currentPlay.questionTopicModel.answers;
      answers.add(
          FileTopicModel.fromJson({'id': 0, 'url': newFileName, 'type': 0}));
      widget.simulatorTestProvider.currentPlay.questionTopicModel.answers =
          answers;
    } catch (e) {
      //Add log
      LogModel? log;
      Map<String, dynamic>? dataLog = {};

      if (context.mounted) {
        log = await Utils.instance().prepareToCreateLog(context,
            action: LogEvent.crash_bug_audio_record);
      }

      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: e.toString(),
        status: LogEvent.failed,
      );
    }
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
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      return TestQuestionWidget(
          isExam: _isExam,
          testId: widget.testDetailModel.testId,
          questions: widget.simulatorTestProvider.questionList,
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
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
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
    bool isPlaying = widget.simulatorTestProvider.isPlaying;
    if (widget.simulatorTestProvider.selectedQuestionIndex != index) {
      if (isPlaying) {
        await _audioPlayer!.stop();
        widget.simulatorTestProvider.setSelectedQuestionIndex(index, false);
      }
      _startPlayAudio(question, index);
    } else {
      if (isPlaying) {
        await _audioPlayer!.stop();
        widget.simulatorTestProvider.setSelectedQuestionIndex(index, false);
      } else {
        _startPlayAudio(question, index);
      }
    }
  }

  void _startPlayAudio(QuestionTopicModel question, int index) async {
    String path = await FileStorageHelper.getFilePath(
        question.answers[question.repeatIndex].url, MediaType.audio, null);
    try {
      await _audioPlayer!.play(AudioPlayers.DeviceFileSource(path),
          mode: PlayerMode.mediaPlayer);
      await _audioPlayer!.setVolume(2.5);
      _audioPlayer!.onPlayerComplete.listen((event) {
        widget.simulatorTestProvider.setSelectedQuestionIndex(index, false);
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    widget.simulatorTestProvider.setSelectedQuestionIndex(index, true);
  }

  Future _reanswerCallBack(QuestionTopicModel question, int index) async {
    bool isPlaying = widget.simulatorTestProvider.isPlaying;
    if (isPlaying) {
      await _audioPlayer!.stop();
      int indexQuestionPlaying =
          widget.simulatorTestProvider.selectedQuestionIndex;
      widget.simulatorTestProvider
          .setSelectedQuestionIndex(indexQuestionPlaying, false);
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ReAnswerDialog(
              context, question, widget.testDetailModel.testId.toString(),
              (question) {
            if (widget.simulatorTestProvider.submitStatus ==
                SubmitStatus.success) {
              widget.simulatorTestProvider.addReanswerQuestion(question);
            }
            widget.simulatorTestProvider.questionList[index] = question;
          });
        });
  }

  @override
  void submitAnswerFail(AlertInfo alertInfo) {
    Utils.instance().sendLog();
    widget.simulatorTestProvider.updateSubmitStatus(SubmitStatus.fail);
    widget.simulatorTestProvider.setVisibleSaveTheTest(true);
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
    Utils.instance().sendLog();
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });
    if (mounted) {
      widget.simulatorTestProvider.clearReasnwersList();
      widget.simulatorTestProvider.setVisibleSaveTheTest(false);
      widget.simulatorTestProvider.updateSubmitStatus(SubmitStatus.success);
    }
  }
  ////////////////////////////CHECK VALUE FUNCTION//////////////////////////////

  int _getCountTimeRecord() {
    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;
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
    return widget.simulatorTestProvider.currentPlay != PlayListModel() &&
            widget.simulatorTestProvider.currentPlay.cueCard.isNotEmpty ||
        widget.simulatorTestProvider.currentPlay.numPart ==
            PartOfTest.part2.get;
  }

  bool _isPart3() {
    return widget.simulatorTestProvider.currentPlay.numPart ==
        PartOfTest.part3.get;
  }

  int _currentNumPart() {
    if (widget.simulatorTestProvider.currentPlay != PlayListModel()) {
      return widget.simulatorTestProvider.currentPlay.numPart;
    }
    return -1;
  }

  double _getSpeedVideo() {
    PlayListModel playListModel = widget.simulatorTestProvider.currentPlay;
    switch (widget.simulatorTestProvider.repeatTimes) {
      case 1:
        return playListModel.firstRepeatSpeed;
      case 2:
        return playListModel.secondRepeatSpeed;
      default:
        return playListModel.normalSpeed;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
