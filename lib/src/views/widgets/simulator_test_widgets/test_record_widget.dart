import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../models/simulator_test_models/question_topic_model.dart';
import '../../../providers/simulator_test_provider.dart';
import '../../../providers/timer_provider.dart';

class TestRecordWidget extends StatelessWidget {
  const TestRecordWidget(
      {super.key, required this.finishAnswer, required this.repeatQuestion});

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;
  final Function(QuestionTopicModel questionTopicModel) repeatQuestion;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    TestRoomProvider simulatorTestProvider =
        Provider.of<TestRoomProvider>(context, listen: false);

    QuestionTopicModel currentQuestion = simulatorTestProvider.currentQuestion;

    bool isRepeat = simulatorTestProvider.enableRepeatButton;

    return Consumer<TestRoomProvider>(builder: (context, provider, _) {
      if (provider.visibleRecord) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: w,
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'You answer is being recorded',
                    style: TextStyle(fontSize: 23),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    AppAssets.img_micro,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 5),
                  Consumer<TestRoomProvider>(builder: (context, provider, _) {
                    return Text(
                      provider.strCountDown,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFinishButton(currentQuestion),
                      Consumer<TestRoomProvider>(
                          builder: (context, provider, _) {
                        if (provider.topicQueue.isNotEmpty) {
                          isRepeat = (provider.topicQueue.first.numPart ==
                                      PartOfTest.part1.get ||
                                  provider.topicQueue.first.numPart ==
                                      PartOfTest.part3.get) &&
                              provider.enableRepeatButton;
                        }

                        return Visibility(
                          visible: isRepeat,
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              _buildRepeatButton(currentQuestion),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget _buildFinishButton(QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        finishAnswer(questionTopicModel);
      },
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.green,
        ),
        alignment: Alignment.center,
        child: const Text(
          'Finish',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatButton(QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        repeatQuestion(questionTopicModel);
      },
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white,
          border: Border.all(width: 1, color: Colors.grey),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Repeat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
