import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/student_test_detail_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/my_test_models/result_response_model.dart';
import '../../../models/my_test_models/skill_problem_model.dart';
import '../../../presenters/response_presenter.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/example_problem_dialog.dart';
import '../../widgets/gradient_border_painter.dart';
import '../../widgets/nothing_widget.dart';

class CorrectionsStudent extends StatefulWidget {
  CorrectionsStudent(
      {required this.activitiesModel,
      required this.studentResultModel,
      required this.provider,
      super.key});
  ActivitiesModel activitiesModel;
  StudentResultModel studentResultModel;
  StudentTestProvider provider;

  @override
  State<CorrectionsStudent> createState() => _CorrectionsStudentState();
}

class _CorrectionsStudentState extends State<CorrectionsStudent>
    implements ResponseContracts {
  bool _selected = true;
  bool _visible = false;
  final double _widthBonus = 35;
  ResponsePresenter? _presenter;
  CircleLoading? _loading;

  double w = 0;
  double h = 0;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = ResponsePresenter(this);
    if (widget.activitiesModel.haveTeacherResponse()) {
      _loading!.show(context);
      _presenter!.getResponse(
          widget.activitiesModel.activityAnswer!.orderId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return buildResultTest();
  }

  Widget buildResultTest() {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    var radius = const Radius.circular(5);
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      ResultResponseModel responseModel = provider.responseModel;
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppColors.opacity,
            borderRadius: BorderRadius.all(radius),
            border: Border.all(color: Colors.black, width: 2)),
        child: (widget.studentResultModel.haveResponse())
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: AppColors.defaultPurpleColor),
                      child: Text(
                          "Overall Score: ${responseModel.overallScore}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: w / 2,
                      child: Text(
                        responseModel.overallComment,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _resultListScreen(responseModel)
                  ],
                ),
              )
            : Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    StringConstants.test_correction_wait_response_message,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColors.defaultBlackColor,
                      fontsSize: FontsSize.fontSize_15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _resultListScreen(ResultResponseModel responseModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            _resultItem('Fluency: ${responseModel.fluency}',
                responseModel.fluencyProblem),
            const SizedBox(height: 20),
            _resultItem('Grammatical: ${responseModel.grammatical}',
                responseModel.grammaticalProblem)
          ],
        ),
        Column(
          children: [
            _resultItem('Lexical Resource: ${responseModel.lexicalResource}',
                responseModel.lexicalResourceProblem),
            const SizedBox(height: 20),
            _resultItem('Pronunciation: ${responseModel.pronunciation}',
                responseModel.pronunciationProblem)
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
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return ExampleProblemDialog(
                              context: context,
                              problem: problem,
                              provider: Provider.of<AuthWidgetProvider>(context,
                                  listen: false),
                            );
                          });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.defaultPurpleColor),
                          borderRadius: BorderRadius.circular(5)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
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

  @override
  void getErrorResponse(String message) {
    if (kDebugMode) {
      print("DEBUG : $message");
    }
    _loading!.hide();
  }

  @override
  void getSuccessResponse(ResultResponseModel responseModel) {
    _loading!.hide();
    widget.provider.setResultResponseModel(responseModel);
  }

  @override
  bool get wantKeepAlive => true;
}
