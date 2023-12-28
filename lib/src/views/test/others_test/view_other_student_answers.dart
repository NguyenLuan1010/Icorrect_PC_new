import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/src/providers/simulator_test_provider.dart';
import 'package:icorrect_pc/src/providers/student_test_detail_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../models/simulator_test_models/test_detail_model.dart';
import '../../../utils/utils.dart';
import '../../dialogs/tip_question_dialog.dart';
import '../../widgets/button_custom.dart';
import '../../widgets/simulator_test_widgets/test_question_widget.dart';
import '../my_test/video_my_test_widget.dart';

class ViewOtherStudentAnswers extends StatefulWidget {
  ViewOtherStudentAnswers(
      {required this.provider,
      required this.activitiesModel,
      required this.testDetailModel,
      super.key});
  StudentTestProvider provider;
  ActivitiesModel activitiesModel;
  TestDetailModel testDetailModel;
  @override
  State<ViewOtherStudentAnswers> createState() =>
      _ViewOtherStudentAnswersState();
}

class _ViewOtherStudentAnswersState extends State<ViewOtherStudentAnswers> {
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
    return SizedBox(
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
          SizedBox(
            width: w,
            height: h / 2.2,
            child: _buildQuestionList(),
          )
        ],
      ),
    );
  }

  Widget _buildSimulatorVideo() {
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      return Container(
        width: w,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.black, width: 2),
            image: const DecorationImage(
                image: AssetImage(AppAssets.bg_test_room), fit: BoxFit.cover)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: w / 3,
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child:
                    // VideoMyTestWidget(testDetailModel: widget.testDetailModel)
                    Container()),
          ],
        ),
      );
    });
  }
 
  Widget _buildQuestionList() {
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      return TestQuestionWidget(
          isExam: false,
          testId: widget.activitiesModel.activityAnswer!.testId,
          questions: provider.questionsList,
          canPlayAnswer: true,
          canReanswer: false,
          isPlayingAnswer: provider.isPlaying,
          selectedQuestionIndex: provider.selectedQuestionIndex,
          playAnswerCallBack: _playAnswerCallBack,
          playReAnswerCallBack: (_, index) {},
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
    if (widget.provider.selectedQuestionIndex != index) {
      if (isPlaying) {
        await _audioPlayer!.stop();
        widget.provider.setSelectedQuestionIndex(index, false);
      }
      _startPlayAudio(question, index);
    } else {
      if (isPlaying) {
        await _audioPlayer!.stop();
        widget.provider.setSelectedQuestionIndex(index, false);
      } else {
        _startPlayAudio(question, index);
      }
    }
  }

  void _startPlayAudio(QuestionTopicModel question, int index) async {
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
