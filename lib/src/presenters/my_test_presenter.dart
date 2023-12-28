import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data_source/api_urls.dart';
import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/file_storage_helper.dart';
import '../data_source/repositories/app_repository.dart';
import '../data_source/repositories/my_test_repository.dart';
import '../models/log_models/log_model.dart';
import '../models/simulator_test_models/file_topic_model.dart';
import '../models/simulator_test_models/question_topic_model.dart';
import '../models/simulator_test_models/test_detail_model.dart';
import '../models/simulator_test_models/topic_model.dart';
import '../models/ui_models/alert_info.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../utils/utils.dart';

abstract class MyTestContract {
  void getMyTestSuccess(TestDetailModel testDetailModel,
      List<QuestionTopicModel> questions, int total);
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total);
  void downloadFilesFail(AlertInfo alertInfo);
  void getMyTestFail(AlertInfo alertInfo);
  void finishCountDown();
  void updateAnswersSuccess(String message);
  void updateAnswerFail(AlertInfo info);
  void onReDownload();
  void onTryAgainToDownload();
}

class MyTestPresenter {
  final MyTestContract? _view;
  MyTestRepository? _repository;

  MyTestPresenter(this._view) {
    _repository = Injector().getMyTestRepository();
  }

  //http.Client? client;
  Dio? dio;
  final Map<String, String> headers = {
    'Accept': 'application/json',
  };

  int _autoRequestDownloadTimes = 0;
  int get autoRequestDownloadTimes => _autoRequestDownloadTimes;
  void increaseAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes += 1;
  }

  TestDetailModel? testDetail;
  List<FileTopicModel>? filesTopic;

  Future<void> initializeData() async {
    dio ??= Dio();
    resetAutoRequestDownloadTimes();
  }

  void resetAutoRequestDownloadTimes() {
    _autoRequestDownloadTimes = 0;
  }

  void closeClientRequest() {
    if (null != dio) {
      dio!.close();
      dio = null;
    }
  }

  Future<void> getMyTest(
      BuildContext context, String activityId, String testId) async {
    assert(_view != null && _repository != null);

    if (kDebugMode) {
      print('DEBUG: testId: ${testId.toString()}');
    }

    LogModel? log;
    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiGetMyTestDetail);
    }

    _repository!.getMyTestDetail(testId).then((value) {
      Map<String, dynamic> json = jsonDecode(value) ?? {};
      if (kDebugMode) {
        print('DEBUG: getMyTestDetail : $value');
      }
      if (json.isNotEmpty) {
        if (json['error_code'] == 200 && json['data'] != null) {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message: null,
            status: LogEvent.success,
          );

          Map<String, dynamic> dataMap = json['data'];
          TestDetailModel testDetailModel =
              TestDetailModel.fromMyTestJson(dataMap);
          testDetail = TestDetailModel.fromMyTestJson(dataMap);

          List<FileTopicModel> tempFilesTopic =
              _prepareFileTopicListForDownload(testDetailModel);

          filesTopic = _prepareFileTopicListForDownload(testDetailModel);

          downloadFiles(context, testDetailModel, tempFilesTopic, activityId);

          _view!.getMyTestSuccess(testDetailModel,
              _getQuestionsAnswer(testDetailModel), tempFilesTopic.length);
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: jsonDecode(value),
            message:
                "Loading my test detail error: ${json[StringConstants.k_error_code]}${json[StringConstants.k_status]}",
            status: LogEvent.failed,
          );
          _view!.getMyTestFail(AlertClass.notResponseLoadTestAlert);
        }
      } else {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: jsonDecode(value),
          message: "Loading my test detail error",
          status: LogEvent.failed,
        );
        _view!.getMyTestFail(AlertClass.getTestDetailAlert);
      }
    }).catchError((onError) {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: null,
        message: onError.toString(),
        status: LogEvent.failed,
      );
      _view!.getMyTestFail(AlertClass.getTestDetailAlert);
    });
  }

  List<QuestionTopicModel> _getQuestionsAnswer(
      TestDetailModel testDetailModel) {
    List<QuestionTopicModel> questions = [];
    List<QuestionTopicModel> questionsAllAnswers = [];
    questions.addAll(testDetailModel.introduce.questionList);
    for (var q in testDetailModel.part1) {
      questions.addAll(q.questionList);
    }

    questions.addAll(testDetailModel.part2.questionList);
    questions.addAll(testDetailModel.part3.questionList);

    for (var question in questions) {
      questionsAllAnswers.addAll(_questionsWithRepeat(question));
    }
    return questionsAllAnswers;
  }

  List<QuestionTopicModel> _questionsWithRepeat(QuestionTopicModel question) {
    List<QuestionTopicModel> repeatQuestions = [];
    List<FileTopicModel> filesAnswers = question.answers;
    for (int i = 0; i < filesAnswers.length - 1; i++) {
      QuestionTopicModel q = _genQuestionRepeat(question, i);
      repeatQuestions.add(q);
    }
    question.repeatIndex = filesAnswers.length - 1;
    repeatQuestions.add(question);
    return repeatQuestions;
  }

  QuestionTopicModel _genQuestionRepeat(
      QuestionTopicModel question, int index) {
    return question.copyWith(
        id: question.id,
        content: Utils.instance()
            .multiLanguage(StringConstants.ask_for_question_title),
        type: question.type,
        topicId: question.topicId,
        tips: question.tips,
        tipType: question.tipType,
        isFollowUp: question.isFollowUp,
        cueCard: question.cueCard,
        reAnswerCount: question.reAnswerCount,
        answers: question.answers,
        numPart: question.numPart,
        repeatIndex: index,
        files: question.files);
  }

  List<FileTopicModel> _prepareFileTopicListForDownload(
      TestDetailModel testDetail) {
    List<FileTopicModel> filesTopic = [];
    filesTopic.addAll(getAllFilesOfTopic(testDetail.introduce));

    for (int i = 0; i < testDetail.part1.length; i++) {
      TopicModel temp = testDetail.part1[i];
      filesTopic.addAll(getAllFilesOfTopic(temp));
    }

    filesTopic.addAll(getAllFilesOfTopic(testDetail.part2));

    filesTopic.addAll(getAllFilesOfTopic(testDetail.part3));
    return filesTopic;
  }

  //Check file is exist using file_storage
  Future<bool> _isExist(String fileName, MediaType mediaType) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(fileName, mediaType, null);
    return isExist;
  }

  MediaType _mediaType(String type) {
    return (type == StringClass.audio) ? MediaType.audio : MediaType.video;
  }

  double _getPercent(int downloaded, int total) {
    return (downloaded / total);
  }

  List<FileTopicModel> getAllFilesOfTopic(TopicModel topic) {
    List<FileTopicModel> allFiles = [];
    //Add introduce file
    allFiles.addAll(topic.files);

    //Add question files
    for (QuestionTopicModel q in topic.questionList) {
      allFiles.add(q.files.first);
      allFiles.addAll(q.answers);
    }

    for (QuestionTopicModel q in topic.followUp) {
      allFiles.add(q.files.first);
      allFiles.addAll(q.answers);
    }

    if (topic.endOfTakeNote.url.isNotEmpty) {
      allFiles.add(topic.endOfTakeNote);
    }

    if (topic.fileEndOfTest.url.isNotEmpty) {
      allFiles.add(topic.fileEndOfTest);
    }

    return allFiles;
  }

  void downloadFailure(AlertInfo alertInfo) {
    _view!.downloadFilesFail(alertInfo);
  }

  Future downloadFiles(
    BuildContext context,
    TestDetailModel testDetail,
    List<FileTopicModel> filesTopic,
    String activityId,
  ) async {
    if (null != dio) {
      loop:
      for (int index = 0; index < filesTopic.length; index++) {
        FileTopicModel temp = filesTopic[index];
        String fileTopic = temp.url;
        String fileNameForDownload =
            Utils.instance().reConvertFileName(fileTopic);

        if (filesTopic.isNotEmpty) {
          LogModel? log;
          if (context.mounted) {
            log = await Utils.instance().prepareToCreateLog(context,
                action: LogEvent.callApiDownloadFile);
            Map<String, dynamic> fileDownloadInfo = {
              StringConstants.k_test_id: testDetail.testId.toString(),
              StringConstants.k_file_name: fileTopic,
              StringConstants.k_file_path: downloadFileEP(fileNameForDownload),
            };

            if (activityId.isNotEmpty) {
              fileDownloadInfo.addEntries(
                  [MapEntry(StringConstants.k_activity_id, activityId)]);
            }
            log.addData(
                key: StringConstants.k_file_download_info,
                value: json.encode(fileDownloadInfo));
          }

          String fileType = Utils.instance().fileType(fileTopic);

          if (_mediaType(fileType) == MediaType.audio) {
            fileNameForDownload = fileTopic;
            fileTopic = Utils.instance().convertFileName(fileTopic);
          }

          if (fileType.isNotEmpty &&
              !await _isExist(fileTopic, _mediaType(fileType))) {
            try {
              String url = downloadFileEP(fileNameForDownload);
              if (kDebugMode) {
                print('DEBUG : fileDownload : $url');
              }
              if (dio == null) {
                if (kDebugMode) {
                  print("DEBUG: client is closed!");
                }
                return;
              }
              dio!.head(url).timeout(const Duration(seconds: 10));
              String savePath =
                  '${await FileStorageHelper.getFolderPath(_mediaType(fileType), null)}\\$fileTopic';
              Response response = await dio!.download(url, savePath);

              if (response.statusCode == 200) {
                if (kDebugMode) {
                  print("DEBUG savePath : $savePath");
                }
                double percent = _getPercent(index + 1, filesTopic.length);
                _view!.onDownloadSuccess(testDetail, fileTopic, percent,
                    index + 1, filesTopic.length);
              } else {
                _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
                // ignore: use_build_context_synchronously
                reDownloadAutomatic(
                    context, testDetail, filesTopic, activityId);
                break loop;
              }
            } on TimeoutException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              // ignore: use_build_context_synchronously
              reDownloadAutomatic(context, testDetail, filesTopic, activityId);
              break loop;
            } on SocketException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              // ignore: use_build_context_synchronously
              reDownloadAutomatic(context, testDetail, filesTopic, activityId);
              break loop;
            } on http.ClientException {
              _view!.downloadFilesFail(AlertClass.downloadVideoErrorAlert);
              // ignore: use_build_context_synchronously
              reDownloadAutomatic(context, testDetail, filesTopic, activityId);
              break loop;
            }
          } else {
            double percent = _getPercent(index + 1, filesTopic.length);
            _view!.onDownloadSuccess(
                testDetail, fileTopic, percent, index + 1, filesTopic.length);
          }
        }
      }
    } else {
      if (kDebugMode) {
        print("DEBUG: client is closed!");
      }
    }
  }

  void reDownloadAutomatic(BuildContext context, TestDetailModel testDetail,
      List<FileTopicModel> filesTopic, String activityId) {
    //Download again
    if (autoRequestDownloadTimes <= 3) {
      if (kDebugMode) {
        print("DEBUG: request to download in times: $autoRequestDownloadTimes");
      }
      downloadFiles(context, testDetail, filesTopic, activityId);
      increaseAutoRequestDownloadTimes();
    } else {
      //Close old download request
      closeClientRequest();
      _view!.onReDownload();
    }
  }

  Future updateMyAnswer(
      {required BuildContext context,
      required String testId,
      required String activityId,
      required List<QuestionTopicModel> reQuestions}) async {
    assert(_view != null && _repository != null);

    //Add log
    LogModel? log;
    Map<String, dynamic> dataLog = {};

    if (context.mounted) {
      log = await Utils.instance()
          .prepareToCreateLog(context, action: LogEvent.callApiUpdateMyAnswer);
    }

    http.MultipartRequest multiRequest = await Utils.instance()
        .formDataRequestSubmit(
            testId: testId,
            activityId: activityId,
            questions: reQuestions,
            isUpdate: true,
            isExam: false);
    try {
      _repository!.updateAnswers(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (kDebugMode) {
          print("DEBUG: error form: ${json.toString()}");
        }
        if (json['error_code'] == 200 && json['status'] == 'success') {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: null,
            status: LogEvent.success,
          );
          _view!.updateAnswersSuccess(Utils.instance()
              .multiLanguage(StringConstants.save_your_answers_success));
        } else {
          //Add log
          Utils.instance().prepareLogData(
            log: log,
            data: dataLog,
            message: StringConstants.update_answer_error_message,
            status: LogEvent.failed,
          );
          _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
        }
      }).catchError((onError) {
        //Add log
        Utils.instance().prepareLogData(
          log: log,
          data: dataLog,
          message: onError.toString(),
          status: LogEvent.failed,
        );
        if (kDebugMode) {
          print('catchError updateAnswerFail ${onError.toString()}');
        }
        _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
      });
    } on TimeoutException {
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: "TimeoutException: Has an error when update my answer!",
        status: LogEvent.failed,
      );
      _view!.updateAnswerFail(AlertClass.timeOutUpdateAnswer);
    } on SocketException {  
      //Add log
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: "SocketException: Has an error when update my answer!",
        status: LogEvent.failed,
      );
      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    } on http.ClientException {
      Utils.instance().prepareLogData(
        log: log,
        data: dataLog,
        message: "ClientException: Has an error when update my answer!",
        status: LogEvent.failed,
      );

      _view!.updateAnswerFail(AlertClass.errorWhenUpdateAnswer);
    }
  }

  void tryAgainToDownload() async {
    if (kDebugMode) {
      print("DEBUG: MyTestPresenter tryAgainToDownload");
    }

    _view!.onTryAgainToDownload();
  }

  void reDownloadFiles(BuildContext context, String activityId) {
    downloadFiles(context, testDetail!, filesTopic!, activityId);
  }
}
