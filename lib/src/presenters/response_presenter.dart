import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/my_test_repository.dart';
import '../models/log_models/log_model.dart';
import '../models/my_test_models/result_response_model.dart';
import '../utils/utils.dart';

abstract class ResponseContracts {
  void getSuccessResponse(ResultResponseModel responseModel);
  void getErrorResponse(String message);
}

class ResponsePresenter {
  final ResponseContracts? _view;
  MyTestRepository? _repository;

  ResponsePresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  void getResponse(BuildContext context, String orderId) async {
    assert(_view != null && _repository != null);
    //Add log
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetResponse);
    }
    _repository!.getResponse(orderId).then((value) {
      Map<String, dynamic> dataMap = jsonDecode(value) ?? {};
      if (kDebugMode) {
        print(dataMap.toString());
      }
      if (dataMap.isNotEmpty) {
        ResultResponseModel responseModel =
            ResultResponseModel.fromJson(dataMap);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        _view!.getSuccessResponse(responseModel);
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: "Loading result response fail!",
          status: LogEvent.failed,
        );
        _view!.getErrorResponse('Loading result response fail !');
      }
    }).catchError((onError) {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );
      _view!.getErrorResponse("Can't load response :${onError.toString()}");
    });
  }
}
