import 'package:flutter/material.dart';

import '../../../../core/app_assets.dart';
import '../../widgets/simulator_test_widgets/test_question_widget.dart';
import '../../widgets/simulator_test_widgets/video_simulator_widget.dart';

class ViewMyAnswers extends StatefulWidget {
  const ViewMyAnswers({super.key});

  @override
  State<ViewMyAnswers> createState() => _ViewMyAnswersState();
}

class _ViewMyAnswersState extends State<ViewMyAnswers> {
  double w = 0;
  double h = 0;
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
            child: _buildQuestionList(),
          )
        ],
      ),
    );
  }

  Widget _buildSimulatorVideo() {
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
          Container(
            width: w / 2,
            alignment: Alignment.center,
            child: Stack(
              children: [],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return TestQuestionWidget(
        testId: 213123123,
        questions: [],
        playAnswerCallBack: (que, sd) {},
        playReAnswerCallBack: (ds, d) {},
        showTipCallBack: (q) {});
  }
}
