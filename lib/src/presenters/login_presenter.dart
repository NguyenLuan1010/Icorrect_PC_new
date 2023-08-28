import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data_source/dependency_injection.dart';
import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../data_source/repositories/auth_repository.dart';
import '../models/app_config_info_models/app_config_info_model.dart';
import '../models/auth_models/auth_model.dart';
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

  void login(String email, String password) {
    assert(_view != null && _repository != null);

    assert(_view != null && _repository != null);

    _repository!.login(email, password).then((value) async {
      AuthModel authModel = AuthModel.fromJson(jsonDecode(value));
      if (authModel.errorCode == 200) {
        await _saveAccessToken(authModel.data.accessToken);
        _getUserInfo();
      } else {
        if (authModel.message.isNotEmpty) {
          _view!.onLoginError('Please check your Internet and try again !');
        } else {
          _view!.onLoginError('${authModel.errorCode}: ${authModel.status}');
        }
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onLoginError('Please check your Internet and try again!');
      } else {
        _view!.onLoginError("An error occur. Please try again!");
      }
    });
  }

  Future<void> _saveAccessToken(String token) async {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void _getUserInfo() async {
    assert(_view != null && _repository != null);

    String deviceId = await Utils.instance().getDeviceIdentifier();
    String appVersion = await Utils.instance().getAppVersion();
    String os = await Utils.instance().getOS();

    _repository!.getUserInfo(deviceId, appVersion, os).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        UserDataModel userDataModel = UserDataModel.fromJson(dataMap['data']);
        Utils.instance().setCurrentUser(userDataModel);
        _view!.onLoginComplete();
      } else {
        _view!.onLoginError(
            "Login error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLoginError(onError.toString()),
    );
  }


}
