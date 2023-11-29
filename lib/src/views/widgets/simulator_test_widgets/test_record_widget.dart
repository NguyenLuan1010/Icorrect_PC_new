import 'package:flutter/foundation.dart';
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
  const TestRecordWidget({
    super.key,
    required this.finishAnswer,
    required this.repeatQuestion,
    required this.simulatorTestProvider
  });

  final Function(QuestionTopicModel questionTopicModel) finishAnswer;
  final Function(QuestionTopicModel questionTopicModel) repeatQuestion;
  final SimulatorTestProvider simulatorTestProvider;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    QuestionTopicModel currentQuestion = simulatorTestProvider.currentQuestion;

    return Consumer<SimulatorTestProvider>(builder: (context, provider, _) {
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
                  Consumer<SimulatorTestProvider>(builder: (context, provider, _) {
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

  Widget _buildFinishButton(SimulatorTestProvider simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
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
              ? const Color.fromARGB(255, 199, 221, 200)
              : const Color.fromARGB(255, 11, 180, 16),
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

  Widget _buildRepeatButton(SimulatorTestProvider simulatorTestProvider,
      PlayListModel playListModel, QuestionTopicModel questionTopicModel) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
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
      SimulatorTestProvider simulatorTestProvider, PlayListModel playListModel) {
    int countTime = Utils.instance().getRecordTime(playListModel.numPart);
    if (kDebugMode) {
      print(
          'counttime : $countTime, currentCount :${simulatorTestProvider.currentCount}');
    }
    return countTime - simulatorTestProvider.currentCount < 2;
  }
}
