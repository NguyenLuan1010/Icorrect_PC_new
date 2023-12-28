import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/practice_repository.dart';
import '../models/my_practice_test_model/my_practice_response_model.dart';
import '../models/my_practice_test_model/my_practice_test_model.dart';

abstract class MyTestsListConstract {
  void getMyTestsListSuccess(MyPracticeResponseModel practiceResponseModel,
      List<MyPracticeTestModel> practiceTests, bool isLoadMore);
  void getMyTestListFail(String message);
  void deleteTestSuccess(String message, int indexDeleted);
  void deleteTestFail(String message);
}

class MyTestsListPresenter {
  final MyTestsListConstract? _view;
  PracticeRepository? _repository;

  MyTestsListPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  Future getMyTestLists(
      {required int pageNum, required bool isLoadMore}) async {
    assert(_view != null && _repository != null);
    _repository!.getMyPracticeTestList(pageNum.toString()).then((value) {
      if (kDebugMode) {
        print("DEBUG:getMyTestLists: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        MyPracticeResponseModel practiceResponseModel =
            MyPracticeResponseModel.fromJson(dataMap);
        _view!.getMyTestsListSuccess(
            practiceResponseModel,
            practiceResponseModel.myPracticeDataModel.myPracticeTests,
            isLoadMore);
      } else {
        _view!.getMyTestListFail(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    }).catchError((error) {
      _view!.getMyTestListFail(
          Utils.instance().multiLanguage(StringConstants.common_error_message));
    });
  }

  Future deleteTest({required int testId, required int index}) async {
    assert(_view != null && _repository != null);

    _repository!.deleteTest(testId.toString()).then((value) {
      if (kDebugMode) {
        print("DEBUG:deleteTest: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        _view!.deleteTestSuccess(
            Utils.instance()
                .multiLanguage(StringConstants.delete_test_success_message),
            index);
      } else {
        _view!.deleteTestFail(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    }).catchError((error) {
      _view!.deleteTestFail(
          Utils.instance().multiLanguage(StringConstants.common_error_message));
    });
  }
}
