import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/my_test_models/skill_problem_model.dart';

import '../../widgets/gradient_border_painter.dart';
import '../../widgets/nothing_widget.dart';

class TeacherResponseWidget extends StatefulWidget {
  TeacherResponseWidget({super.key});

  @override
  State<TeacherResponseWidget> createState() => _TeacherResponseWidgetState();
}

class _TeacherResponseWidgetState extends State<TeacherResponseWidget> {
  bool _selected = true;
  bool _visible = false;
  double _widthBonus = 35;

  double w = 0;
  double h = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildResultTest();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  Widget buildResultTest() {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    var radius = const Radius.circular(5);
    return LayoutBuilder(builder: (context, constaint) {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppColors.opacity,
            borderRadius: BorderRadius.all(radius),
            border: Border.all(color: Colors.black, width: 2)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: AppColors.defaultPurpleColor),
                child: Text("Overall Score: 8.0",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: w / 2,
                child: Text(
                  "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              _resultListScreen()
            ],
          ),
        ),
      );
    });
  }

  Widget _resultListScreen() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            _resultItem('Fluency: 8.0', []),
            const SizedBox(height: 20),
            _resultItem('Grammatical: 8.0', [])
          ],
        ),
        Column(
          children: [
            _resultItem('Lexical Resource: 8.0', []),
            const SizedBox(height: 20),
            _resultItem('Pronunciation: 8.0', [])
          ],
        )
      ],
    );
  }

  Widget _resultItem(String title, List<SkillProblem> problems) {
    double width = 400, height = 200;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Container(
            width: width,
            height: height + (_visible ? _widthBonus : -_widthBonus),
            padding: EdgeInsets.zero,
            child: AnimatedAlign(
                alignment:
                    _selected ? Alignment.topRight : Alignment.bottomLeft,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                onEnd: () {
                  _visible = !_selected;
                },
                child: Visibility(
                    visible: _visible,
                    child: Container(
                      width: width,
                      height: height,
                      margin: EdgeInsets.zero,
                      child: CustomPaint(
                          painter: GradientBorderPainter(width, height),
                          child: (problems.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: problems.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _problemItem(
                                        index, problems.elementAt(index));
                                  })
                              : NothingWidget.init().buildNothingWidget(
                                  'No Problem and Solution in here.',
                                  widthSize: 150,
                                  heightSize: 150)),
                    ))),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              _selected = !_selected;
              _visible = !_selected;
            });
          },
          child: Container(
            width: width - 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.defaultPurpleColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)),
                (_selected)
                    ? const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _problemItem(int index, SkillProblem problem) {
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.stop();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber),
                const SizedBox(width: 10),
                Text("Problem ${index > 0 ? index : ''}: ",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(problem.problem.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.light_mode_outlined, color: Colors.amber),
                    const SizedBox(width: 10),
                    Text("Solution ${index > 0 ? index : ''}: ",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              Visibility(
                  visible: problem.exampleText.isNotEmpty,
                  child: InkWell(
                    onTap: () {
                      // ExampleProblemDialog dialog = ExampleProblemDialog();
                      // showDialog(
                      //     context: context,
                      //     barrierDismissible: false,
                      //     builder: (context) {
                      //       return dialog.showDialog(context, problem);
                      //     });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.defaultPurpleColor),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text('Xem ví dụ',
                            style: TextStyle(
                                color: AppColors.defaultPurpleColor,
                                fontSize: 13)),
                      ),
                    ),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(problem.solution.toString(),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300)),
          )
        ],
      ),
    );
  }
}
