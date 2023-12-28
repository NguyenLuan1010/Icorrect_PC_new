import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/data_source/dependency_injection.dart';
import 'package:icorrect_pc/src/data_source/repositories/auth_repository.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../models/app_config_info_models/app_config_info_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthConstract {
  void onGetAppConfigInfoSuccess();
  void onGetAppConfigInfoFail(String message);
}

class AuthPresenter {
  final AuthConstract? _view;
  AuthRepository? _repository;

  AuthPresenter(this._view) {
    _repository = Injector().getAuthRepository();
  }

  void getAppConfigInfo() {
    assert(_view != null && _repository != null);

    _repository!.getAppConfigInfo().then((value) async {
      if (kDebugMode) {
        print("DEBUG: getAppConfigInfo $value");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        AppConfigInfoModel appConfigInfoModel =
            AppConfigInfoModel.fromJson(dataMap);
        String logApiUrl = appConfigInfoModel.data.logUrl.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance()
              .putString(key: AppSharedKeys.logApiUrl, value: logApiUrl);
        }

        String secretkey = appConfigInfoModel.data.secretkey.toString();
        if (logApiUrl.isNotEmpty) {
          AppSharedPref.instance()
              .putString(key: AppSharedKeys.secretkey, value: secretkey);
        }

        _view!.onGetAppConfigInfoSuccess();
      } else {
        _view!.onGetAppConfigInfoFail(
            "${Utils.instance().multiLanguage(StringConstants.login_error_title)}: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError((onError) {
      if (onError is http.ClientException || onError is SocketException) {
        _view!.onGetAppConfigInfoFail(Utils.instance()
            .multiLanguage(StringConstants.network_error_message));
      } else {
        _view!.onGetAppConfigInfoFail(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    });
  }
}
