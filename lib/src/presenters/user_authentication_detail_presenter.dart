import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/data_source/dependency_injection.dart';
import 'package:icorrect_pc/src/data_source/repositories/user_authen_repository.dart';
import 'package:icorrect_pc/src/models/log_models/log_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/models/user_authentication/user_authentication_detail.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:http/http.dart' as http;

import '../data_source/local/file_storage_helper.dart';

abstract class UserAuthDetailContract {
  void getUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel);
  void getUserAuthDetailFail(String message);
  void userNotFoundWhenLoadAuth(String message);
  void downloadVideoSuccess(String savePath);
  void downloadVideoFail(AlertInfo alertInfo);
}

class UserAuthDetailPresenter {
  final UserAuthDetailContract? _view;
  UserAuthRepository? _repository;

  UserAuthDetailPresenter(this._view) {
    _repository = Injector().getUserAuthDetailRepository();
  }

  Future getUserAuthDetail(BuildContext context) async {
    assert(_view != null);
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance().prepareToCreateLog(context,
          action: LogEvent.callApiGetUserAuthDetail);
    }

    _repository!.getUserAuthDetail().then((value) {
      Map<String, dynamic> map = jsonDecode(value);

      if (kDebugMode) {
        print('dada: ${map.toString()}');
      }

      if (map['error_code'] == 200 && map['status'] == 'success') {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: null,
          status: LogEvent.success,
        );

        Map<String, dynamic> data = map['data'] ?? {};
        if (data.isNotEmpty) {
          UserAuthenDetailModel userAuthenDetailModel =
              UserAuthenDetailModel.fromJson(data);
          _view!.getUserAuthDetailSuccess(userAuthenDetailModel);
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: null,
            message:
                "You have not been added to the testing system, please contact admin for better understanding!",
            status: LogEvent.failed,
          );

          _view!.userNotFoundWhenLoadAuth(
              "You have not been added to the testing system, please contact admin for better understanding!");
        }
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: null,
          message: "Something went wrong when load your authentication!",
          status: LogEvent.failed,
        );
        _view!.getUserAuthDetailFail(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    }).catchError((e) {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: "Something went wrong when load your authentication!",
        status: LogEvent.failed,
      );
      _view!.getUserAuthDetailFail(
          "${Utils.instance().multiLanguage(StringConstants.load_error)} : ${e.toString()}!");
    });
  }

  Future downloadVideoAuth(String nameVideo, String url) async {
    String nameFile = Utils.instance().convertFileName(nameVideo);
    String savePath =
        '${await FileStorageHelper.getFolderPath(MediaType.video, null)}\\$nameFile';
    if (!await _isExist(nameFile, MediaType.video)) {
      try {
        Dio dio = Dio();
        dio.head(url).timeout(const Duration(seconds: 2));
        Response response = await dio.download(url, savePath);
        if (response.statusCode == 200) {
          _view!.downloadVideoSuccess(savePath);
        } else {
          _view!.downloadVideoFail(AlertClass.downloadVideoErrorAlert);
        }
      } on TimeoutException {
        _view!.downloadVideoFail(AlertClass.downloadVideoErrorAlert);
      } on SocketException {
        _view!.downloadVideoFail(AlertClass.downloadVideoErrorAlert);
      } on http.ClientException {
        _view!.downloadVideoFail(AlertClass.downloadVideoErrorAlert);
      }
    } else {
      _view!.downloadVideoSuccess(savePath);
    }
  }

  Future<bool> _isExist(String fileName, MediaType mediaType) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(fileName, mediaType, null);
    return isExist;
  }
}
