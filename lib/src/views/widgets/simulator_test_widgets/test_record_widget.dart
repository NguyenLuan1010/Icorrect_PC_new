import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/playlist_model.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

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

    return Consumer<TestRoomProvider>(builder: (context, provider, _) {
      PlayListModel playListModel = provider.currentPlay;
      bool enableRepeat = ((playListModel.numPart == PartOfTest.part1.get ||
              playListModel.numPart == PartOfTest.part3.get) &&
          provider.repeatTimes <= 1);
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
                      _buildFinishButton(simulatorTestProvider, playListModel,
                          currentQuestion),
                      Visibility(
                        visible: enableRepeat,
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            _buildRepeatButton(simulatorTestProvider,
                                playListModel, currentQuestion),
                          ],
                        ),
                      )
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

  Widget _buildFinishButton(TestRoomProvider simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        if (!_lessThan2s(simulatorTestProvider, playListModel)) {
          finishAnswer(questionTopicModel);
        }
      },
      child: Container(
        width: 100,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _lessThan2s(simulatorTestProvider, playListModel)
              ? const Color.fromARGB(255, 130, 227, 134)
              : Colors.green,
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

  Widget _buildRepeatButton(TestRoomProvider simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      onTap: () {
        if (!_lessThan2s(simulatorTestProvider, playListModel)) {
          repeatQuestion(questionTopicModel);
        }
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

  bool _lessThan2s(
      TestRoomProvider simulatorTestProvider, PlayListModel playListModel) {
    int countTime = Utils.instance().getRecordTime(playListModel.numPart);
    print(
        'counttime : $countTime, currentCount :${simulatorTestProvider.currentCount}');
    return countTime - simulatorTestProvider.currentCount <= 2;
  }
}
