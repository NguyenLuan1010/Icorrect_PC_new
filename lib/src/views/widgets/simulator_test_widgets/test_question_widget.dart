import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/widgets/divider.dart';
import 'package:icorrect_pc/src/views/widgets/grid_view_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/simulator_test_models/file_topic_model.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../providers/play_answer_provider.dart';
import '../../../providers/simulator_test_provider.dart';
import '../../dialogs/focus_image_dialog.dart';

class TestQuestionWidget extends StatelessWidget {
  TestQuestionWidget({
    super.key,
    required this.isExam,
    required this.testId,
    required this.questions,
    required this.canReanswer,
    required this.canPlayAnswer,
    required this.isPlayingAnswer,
    required this.selectedQuestionIndex,
    required this.playAnswerCallBack,
    required this.playReAnswerCallBack,
    required this.showTipCallBack,
  });

  int testId, selectedQuestionIndex;
  bool canReanswer, canPlayAnswer, isPlayingAnswer, isExam;
  List<QuestionTopicModel> questions;
  final Function(
          QuestionTopicModel questionTopicModel, int selectedQuestionIndex)
      playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel, int indexQuestion)
      playReAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;
  double w = 0, h = 0;

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    if (questions.isEmpty) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        height: 300,
        child: Text(
          Utils.instance().multiLanguage(
              StringConstants.no_answer_please_start_your_test_message),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      double h = MediaQuery.of(context).size.height / 2;
      double w = MediaQuery.of(context).size.width;
      return Container(
        height: h,
        padding: const EdgeInsets.symmetric(vertical: 30),
        // child: isExam
        //     ? ListView.builder(
        //         itemCount: questions.length,
        //         itemBuilder: (_, index) {
        //           QuestionTopicModel question = questions.elementAt(index);
        //           return _buildTestQuestionItem(context, question, index);
        //         })
        //     : MyGridView(
        //         data: questions,
        //         itemWidget: (dynamic itemModel, int index) {
        //           QuestionTopicModel question = itemModel;
        //           return _buildTestQuestionItem(context, question, index);
        //         }),
        child: (w < SizeLayout.QuestionsListSize)
            ? _buildQuestionsTabletLayout()
            : _buildQuestionsDesktopLayout(context),
      );
    }
  }

  Widget _buildQuestionsDesktopLayout(BuildContext context) {
    return MyGridView(
        data: questions,
        itemWidget: (dynamic itemModel, int index) {
          QuestionTopicModel question = itemModel;
          return _buildTestQuestionItem(context, question, index);
        });
  }

  Widget _buildQuestionsTabletLayout() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return _buildTestQuestionItem(
              context, questions.elementAt(index), index);
        });
  }

  Widget _buildTestQuestionItem(
      BuildContext context, QuestionTopicModel question, int index) {
    bool hasCueCard = false;
    String questionStr = question.content;
    double w = MediaQuery.of(context).size.width / 3;
    double h = MediaQuery.of(context).size.height / 1.8;
    if (question.cueCard.trim().isNotEmpty) {
      hasCueCard = true;
      questionStr = question.cueCard;
    }

    String iconPath;
    if (isPlayingAnswer && index == selectedQuestionIndex) {
      iconPath = AppAssets.img_pause;
    } else {
      iconPath = AppAssets.img_play;
    }

    Future<String> imagePath = _getImagePath(question);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: hasCueCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.black
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  question.cueCard.trim(),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.black
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (canPlayAnswer)
                    InkWell(
                      onTap: () {
                        playAnswerCallBack(question, index);
                      },
                      child: Image(
                        image: AssetImage(iconPath),
                        width: 50,
                        height: 50,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !hasCueCard
                          ? SizedBox(
                              width: w,
                              child: Text(
                                questionStr,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (canReanswer)
                                InkWell(
                                  onTap: () {
                                    playReAnswerCallBack(question, index);
                                  },
                                  child: Text(
                                    Utils.instance().multiLanguage(
                                        StringConstants.re_answer_button_title),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              Visibility(
                                visible: question.tips.isNotEmpty,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () {
                                        showTipCallBack(question);
                                      },
                                      child: Text(
                                        Utils.instance().multiLanguage(
                                            StringConstants
                                                .view_tips_button_title),
                                        style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              FutureBuilder(
                  future: imagePath,
                  builder: (context, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return FocusImageDialog(
                                    context, snapshot.data ?? "");
                              });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.defaultPurpleColor),
                                borderRadius: BorderRadius.circular(10)),
                            width: 80,
                            height: 50,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(snapshot.data ?? ''),
                                ))),
                      );
                    }
                    return Container();
                  })
            ],
          ),
          const SizedBox(height: 5),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.defaultGrayColor,
          )
        ],
      ),
    );
  }

  Future<String> _getImagePath(QuestionTopicModel questionTopicModel) async {
    List<FileTopicModel> filesImage = _getFilesImage(questionTopicModel.files);
    if (filesImage.isNotEmpty) {
      String fileName = filesImage.first.url;
      return await FileStorageHelper.getFilePath(
          fileName, MediaType.image, null);
    }
    return "";
  }

  List<FileTopicModel> _getFilesImage(List<FileTopicModel> files) {
    return files
        .where((element) =>
            Utils.instance().mediaType(element.url) == MediaType.image)
        .toList();
  }
}
