import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/presenters/my_test_presenter.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/dialogs/tip_question_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../providers/my_test_provider.dart';
import '../../dialogs/re_answer_dialog.dart';
import '../../widgets/button_custom.dart';
import '../../widgets/simulator_test_widgets/test_question_widget.dart';
import '../../widgets/simulator_test_widgets/video_simulator_widget.dart';

class ViewMyAnswers extends StatefulWidget {
  Function clickUpdateReanswerCallBack;
  ActivitiesModel activitiesModel;
  MyTestProvider provider;
  ViewMyAnswers(
      {required this.clickUpdateReanswerCallBack,
      required this.activitiesModel,
      required this.provider,
      super.key});

  @override
  State<ViewMyAnswers> createState() => _ViewMyAnswersState();
}

class _ViewMyAnswersState extends State<ViewMyAnswers> {
  double w = 0;
  double h = 0;

  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Container(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: w,
            height: h / 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildSimulatorVideo(),
          ),
          Container(
            width: w,
            height: h / 2.2,
            child: _buildQuestionList(),
          )
        ],
      ),
    );
  }

  Widget _buildSimulatorVideo() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return Container(
        width: w,
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
              // child: VideoSimulatorWidget(
              //     roomProvider: _roomProvider!,
              //     onVideoEnd: () {
              //       _onVideoEnd();
              //     }),
            ),
            Visibility(
                visible: provider.reAnswerQuestions.isNotEmpty,
                child: Container(
                  width: w / 2,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(AppAssets.img_QA),
                        width: 100,
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 250,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            // widget.myTestPresenter.updateMyAnswer(
                            //     testId:
                            //         widget.testDetailModel.testId.toString(),
                            //     activityId: widget.activitiesModel.activityId
                            //         .toString(),
                            //     reQuestions: widget.provider.reAnswerQuestions);
                            widget.clickUpdateReanswerCallBack();
                          },
                          style: ButtonCustom.init().buttonPurple20(),
                          child: const Text(
                            "Update Your Test",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );
    });
  }

  Widget _buildQuestionList() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      return TestQuestionWidget(
          isExam: false,
          testId: widget.activitiesModel.activityAnswer!.testId,
          questions: provider.questionsList,
          canPlayAnswer: true,
          canReanswer: widget.activitiesModel.canReanswer(),
          isPlayingAnswer: provider.isPlaying,
          selectedQuestionIndex: provider.selectedQuestionIndex,
          playAnswerCallBack: _playAnswerCallBack,
          playReAnswerCallBack: _reanswerCallBack,
          showTipCallBack: _showTipDialog);
    });
  }

  void _showTipDialog(QuestionTopicModel question) {
    showDialog(
        context: context,
        builder: (context) {
          return TipQuestionDialog(context, question);
        });
  }

  Future _playAnswerCallBack(QuestionTopicModel question, int index) async {
    bool isPlaying = widget.provider.isPlaying;
    if (isPlaying) {
      await _audioPlayer!.stop();
      widget.provider.setSelectedQuestionIndex(index, false);
    } else {
      String fileName = Utils.instance()
          .convertFileName(question.answers[question.repeatIndex].url);
      String path =
          await FileStorageHelper.getFilePath(fileName, MediaType.audio, null);
      try {
        await _audioPlayer!.play(DeviceFileSource(path));
        await _audioPlayer!.setVolume(2.5);
        _audioPlayer!.onPlayerComplete.listen((event) {
          widget.provider.setSelectedQuestionIndex(index, false);
        });
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("DEBUG : Error Path play audio: $e");
        }
        widget.provider.setSelectedQuestionIndex(index, false);
      }
      widget.provider.setSelectedQuestionIndex(index, true);
    }
  }

  Future _reanswerCallBack(QuestionTopicModel question, int index) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ReAnswerDialog(context, question,
              widget.activitiesModel.activityAnswer!.testId.toString(),
              (question) {
            int reanswerCount =
                widget.provider.questionsList[index].reAnswerCount;
            widget.provider.questionsList[index].reAnswerCount =
                reanswerCount + 1;
            widget.provider.questionsList[index].answers.last.url =
                question.answers.last.url;
            widget.provider
                .addReanswerQuestion(widget.provider.questionsList[index]);
          });
        });
  }
}
