// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/auth_repository.dart';
import '../models/log_models/log_model.dart';
import '../utils/utils.dart';

abstract class ChangePasswordViewContract {
  void onChangePasswordComplete();
  void onChangePasswordError(String message);
}

class ChangePasswordPresenter {
  final ChangePasswordViewContract? _view;
  AuthRepository? _authRepository;

  ChangePasswordPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
  }

  void changePassword(
    BuildContext context,
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    assert(_view != null && _authRepository != null);
    LogModel? log;
    if (context.mounted) {
      //Add action log
      LogModel actionLog = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.actionChangePassword);
      Utils.instance().addLog(actionLog, LogEvent.none);

      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiChangePassword);
    }

    _authRepository!
        .changePassword(oldPassword, newPassword, confirmNewPassword)
        .then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap[StringConstants.k_error_code] == 200) {
        Map<String, dynamic> map = dataMap[StringConstants.k_data];
        String token = map[StringConstants.k_access_token];
        Utils.instance().setAccessToken(token);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: dataMap[StringConstants.k_message],
          status: LogEvent.success,
        );

        _view!.onChangePasswordComplete();
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message:
              "${StringConstants.change_password_error_title}: ${dataMap['error_code']}${dataMap['status']}",
          status: LogEvent.failed,
        );

        _view!.onChangePasswordError(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );

        _view!.onChangePasswordError(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      },
    );
  }
}
