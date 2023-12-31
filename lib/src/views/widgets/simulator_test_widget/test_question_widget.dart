import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/views/widgets/divider.dart';
import 'package:icorrect_pc/src/views/widgets/grid_view_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../presenters/test_room_presenter.dart';
import '../../../providers/play_answer_provider.dart';
import '../../../providers/simulator_test_provider.dart';

class TestQuestionWidget extends StatelessWidget {
  const TestQuestionWidget({
    super.key,
    required this.testRoomPresenter,
    required this.playAnswerCallBack,
    required this.playReAnswerCallBack,
    required this.showTipCallBack,
  });

  final TestRoomPresenter testRoomPresenter;
  final Function(
          QuestionTopicModel questionTopicModel, int selectedQuestionIndex)
      playAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) playReAnswerCallBack;
  final Function(QuestionTopicModel questionTopicModel) showTipCallBack;

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        if (simulatorTestProvider.questionList.isEmpty) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(20),
            height: 300,
            child: const Text(
              "Oops, No answer here, please start your test!",
              style: TextStyle(
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
            child: MyGridView(
                data: simulatorTestProvider.questionList,
                itemWidget: (dynamic itemModel, int index) {
                  QuestionTopicModel question = itemModel;
                  return _buildTestQuestionItem(context, question, index);
                }),
          );
        }
      },
    );
  }

  Widget _buildTestQuestionItem(
      BuildContext context, QuestionTopicModel question, int index) {
    bool hasCueCard = false;
    String questionStr = question.content;
    double w = MediaQuery.of(context).size.width / 3;
    double h = MediaQuery.of(context).size.height / 1.8;
    if (question.cueCard.trim().isNotEmpty) {
      hasCueCard = true;
      questionStr = 'Answer of Part 2';
    }

    SimulatorTestProvider prepareSimulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    bool hasReAnswer = false;
    if (prepareSimulatorTestProvider.activityType == "homework") {
      hasReAnswer = true;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: hasCueCard,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.content,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    question.cueCard.trim(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(color: AppColors.defaultPurpleColor, height: 1),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: w,
                    child: Text(
                      questionStr,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (hasReAnswer)
                            InkWell(
                              onTap: () {
                                playReAnswerCallBack(question);
                              },
                              child: const Text(
                                "Re-answer",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            Visibility(
                              visible: question.tips.isNotEmpty,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20),
                                  InkWell(
                                    onTap: () {
                                      showTipCallBack(question);
                                    },
                                    child: const Text(
                                      "View tips",
                                      style: TextStyle(
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
              ),
              Consumer<PlayAnswerProvider>(
                  builder: (context, playAnswerProvider, _) {
                String iconPath;
                if (index == playAnswerProvider.selectedQuestionIndex) {
                  iconPath = AppAssets.img_pause;
                } else {
                  iconPath = AppAssets.img_play;
                }

                return InkWell(
                  onTap: () {
                    playAnswerCallBack(question, index);
                  },
                  child: Image(
                    image: AssetImage(iconPath),
                    width: 50,
                    height: 50,
                  ),
                );
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
}
