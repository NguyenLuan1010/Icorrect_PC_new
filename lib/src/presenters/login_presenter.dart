import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../data_source/repositories/auth_repository.dart';
import '../models/app_config_info_models/app_config_info_model.dart';
import '../models/auth_models/auth_model.dart';
import '../models/log_models/log_model.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;

abstract class LoginViewContract {
  void onLoginComplete();
  void onLoginError(String message);
}

class LoginPresenter {
  final LoginViewContract? _view;
  AuthRepository? _repository;
  LoginPresenter(this._view) {
    _repository = Injector().getAuthRepository();
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    assert(_view != null && _repository != null);

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiLogin);
    }

    _repository!.login(email, password).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      if (authModel.errorCode == 200) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.message,
          status: LogEvent.success,
        );
        await _saveAccessToken(authModel.data.accessToken);
        // ignore: use_build_context_synchronously
        _getUserInfo(context);
      } else if (authModel.errorCode == 401) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: authModel.status,
          status: LogEvent.success,
        );
        _view!.onLoginError(authModel.status);
      } else {
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError(Utils.instance().multiLanguage(Utils.instance()
              .multiLanguage(StringConstants.network_error_message)));
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: StringConstants.network_error_message,
            status: LogEvent.failed,
          );
        } else {
          _view!.onLoginError(Utils.instance()
              .multiLanguage(StringConstants.common_error_message));
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: '${authModel.errorCode}: ${authModel.status}',
            status: LogEvent.failed,
          );
        }
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.network_error_message,
          status: LogEvent.failed,
        );
      } else {
        _view!.onLoginError(StringConstants.common_error_message);
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: StringConstants.common_error_message,
          status: LogEvent.failed,
        );
      }
    });
  }

  Future<void> _saveAccessToken(String token) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void _getUserInfo(BuildContext context) async {
    assert(_view != null && _repository != null);

    String deviceId = await Utils.instance().getDeviceIdentifier();
    String appVersion = await Utils.instance().getAppVersion();
    String os = await Utils.instance().getOS();
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetUserInfo);
    }
    _repository!.getUserInfo(deviceId, appVersion, os).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        UserDataModel userDataModel = UserDataModel.fromJson(dataMap['data']);
        Utils.instance().setCurrentUser(userDataModel);

        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );
        _view!.onLoginComplete();
      } else {
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message:
              "GetUserInfo error: ${dataMap[StringConstants.k_error_code]}${dataMap[StringConstants.k_status]}",
          status: LogEvent.failed,
        );

        _view!.onLoginError(
            "${Utils.instance().multiLanguage(StringConstants.login_error_title)}:"
            "${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      (onError) {
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: onError.toString(),
          status: LogEvent.failed,
        );
        _view!.onLoginError(onError.toString());
      },
    );
  }
}
