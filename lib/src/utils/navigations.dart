import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect_pc/src/providers/student_test_detail_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth_screen_manager.dart';
import 'package:icorrect_pc/src/views/test/my_test/my_test_screen.dart';
import 'package:icorrect_pc/src/views/test/others_test/other_student_test_screen.dart';
import 'package:provider/provider.dart';

import '../providers/my_test_provider.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/main_screen_manager.dart';
import '../views/test/my_test/my_test_screen.dart';
import '../views/test/simulator_test/simulator_test_screen.dart';

class Navigations {
  Navigations._();
  static final Navigations _navigation = Navigations._();
  factory Navigations.instance() => _navigation;

  void goToLogin(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginWidget()));
  }

  // void goToRegister(BuildContext context) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => const RegisterWidget()));
  // }

  // void goToForgotPassword(BuildContext context) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => const FotgotPasswordWidget()));
  // }
  void goToAuthWidget(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AuthWidget()));
  }

  void goToMainWidget(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainWidget()));
  }

  void goToSimulatorTestRoom(
      BuildContext context, ActivitiesModel activitiesModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SimulatorTestScreen(homeWorkModel: activitiesModel)));
  }

  void goToMyTest(BuildContext context, ActivitiesModel activitiesModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyTestScreen(homeWork: activitiesModel),
      ),
    );
  }

  void goToOtherStudentTestScreen(BuildContext context,
      StudentResultModel studentResultModel, ActivitiesModel activitiesModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
            create: (_) => StudentTestProvider(),
            child: OtherStudentTestScreen(
                resultModel: studentResultModel, homeWork: activitiesModel)),
      ),
    );
  }

  // void goToTopicDetailWidget(BuildContext context, HomeWorks homeWork) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => TopicDetailWidget(homework: homeWork)));
  // }
}
