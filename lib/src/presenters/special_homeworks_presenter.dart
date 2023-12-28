import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/my_test_repository.dart';
import '../models/log_models/log_model.dart';
import '../models/my_test_models/student_result_model.dart';
import '../utils/utils.dart';

abstract class SpecialHomeworksContracts {
  void getSpecialHomeWork(List<StudentResultModel> studentsResults);
  void getSpecialHomeWorksFail(String message);
}

class SpecialHomeworksPresenter {
  final SpecialHomeworksContracts? _view;
  MyTestRepository? _myTestRepository;

  SpecialHomeworksPresenter(this._view) {
    _myTestRepository = Injector().getMyTestRepository();
  }

  Future<void> getSpecialHomeWorks({
    required BuildContext context,
    required String email,
    required String activityId,
    required int status,
    required int example,
  }) async {
    assert(_view != null && _myTestRepository != null);
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance().prepareToCreateLog(context,
          action: LogEvent.callApiGetSpecialHomework);
    }
    _myTestRepository!
        .getSpecialHomeWorks(email, activityId, status, example)
        .then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? {};

      if (kDebugMode) {
        print("DEBUG: getSpecialHomeWorks: result: ${value.toString()}");
      }

      if (dataMap.isNotEmpty) {
        if (dataMap['error_code'] == 200) {
          List<StudentResultModel> results =
              _getStudentResultsModel(dataMap['data'] ?? []);
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );
          _view!.getSpecialHomeWork(results);
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.get_special_homework_error_message,
            status: LogEvent.failed,
          );
          _view!.getSpecialHomeWorksFail(StringConstants.load_result_response_fail);
        }
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: StringConstants.get_special_homework_error_message,
          status: LogEvent.failed,
        );
        _view!.getSpecialHomeWorksFail(
            StringConstants.load_result_response_fail);
      }
    }).catchError((onError) {
      String message = '';
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );

      if (onError is SocketException) {
        message = StringConstants.network_error_message;
      } else {
        message = StringConstants.common_error_message;
      }
      _view!.getSpecialHomeWorksFail(
          '${StringConstants.loading_error_homeworks_list} : ${onError.toString()}');
      if (kDebugMode) {
        print("DEBUG: getSpecialHomeWorks ${onError.toString()}");
      }
    });
  }

  List<StudentResultModel> _getStudentResultsModel(List<dynamic> data) {
    if (kDebugMode) {
      print("DEBUG: _getStudentResultsModel ${data.toString()}");
    }
    List<StudentResultModel> results = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];
      results.add(StudentResultModel.fromJson(item));
    }
    return results;
  }
}
