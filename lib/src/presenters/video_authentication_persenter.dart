// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:icorrect_pc/src/data_source/api_urls.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/data_source/dependency_injection.dart';
import 'package:icorrect_pc/src/data_source/repositories/user_authen_repository.dart';
import 'package:icorrect_pc/src/models/log_models/log_model.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

abstract class VideoAuthenticationContract {
  void onCountRecording(Duration currentCount, String strCount);
  void onFinishRecording();
  void submitAuthSuccess(File savedFile, String message);
  void submitAuthFail(String message);
}

class VideoAuthenticationPresenter {
  final VideoAuthenticationContract? _view;
  UserAuthRepository? _repository;
  VideoAuthenticationPresenter(this._view) {
    _repository = Injector().getUserAuthDetailRepository();
  }

  Timer startCountRecording({required Duration durationFrom}) {
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (timer) {
      durationFrom += const Duration(seconds: 1);

      if (durationFrom.inSeconds == 60) {
        _view!.onFinishRecording();
      } else {
        String strCount = formatDuration(durationFrom);
        _view!.onCountRecording(durationFrom, strCount);
      }
    });
  }

  String formatDuration(Duration duration) {
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future submitAuth({
    required File authFile,
    required isUploadVideo,
    required BuildContext context,
  }) async {
    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiSubmitAuth);
    }

    String url = submitAuthEP();
    http.MultipartRequest multiRequest =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    multiRequest.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.instance().getAccessToken()}'
    });

    multiRequest.files
        .add(await http.MultipartFile.fromPath('video', authFile.path));
    try {
      _repository!.submitAuth(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};

        if (kDebugMode) {
          print("DEBUG:form response: ${json.toString()}");
        }

        if (json['error_code'] == 200 && json['status'] == 'success') {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message:
                "Submit file to authentication successfully. Waiting for confirmation!",
            status: LogEvent.success,
          );

          _view!.submitAuthSuccess(authFile,
              "Submit file to authentication successfully. Waiting for confirmation!");
        } else {
          List<String> categoriesList = List<String>.from(isUploadVideo
              ? json['data']['video'] ?? []
              : json['data']['audio'] ?? []);

          _view!.submitAuthFail(
              'Error : ${categoriesList.toString().replaceAll(RegExp(r'[\[\]]'), "")}');
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: "Submit file to authentication fail!",
            status: LogEvent.failed,
          );
        }
      });
    } on TimeoutException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: "Submit file to authentication fail: TimeoutException!",
        status: LogEvent.failed,
      );
      _view!.submitAuthFail("Please check your internet and try again !");
    } on SocketException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: "Submit file to authentication fail: SocketException!",
        status: LogEvent.failed,
      );
      _view!.submitAuthFail("Please check your internet and try again !");
    } on http.ClientException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: "Submit file to authentication fail: ClientException!",
        status: LogEvent.failed,
      );
      _view!.submitAuthFail("Please check your internet and try again !");
    }
  }
}
