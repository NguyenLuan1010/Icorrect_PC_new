import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/file_storage_helper.dart';
import '../data_source/repositories/simulator_test_repository.dart';
import '../models/simulator_test_models/playlist_model.dart';
import 'package:http/http.dart' as http;

abstract class TestRoomSimulatorContract {
  void playFileVideo(File normalFile, File slowFile);
  void onCountDown(String strCount);
  void onFinishAnswer(bool isPart2);
  void onCountDownForCueCard(String strCount);
  void submitAnswersSuccess(AlertInfo alertInfo);
  void submitAnswerFail(AlertInfo alertInfo);
}

class TestRoomSimulatorPresenter {
  final TestRoomSimulatorContract? _view;
  SimulatorTestRepository? _repository;

  TestRoomSimulatorPresenter(this._view) {
    _repository = Injector().getTestRepository();
  }

  List<TopicModel> getListTopicModel(TestDetailModel testDetailModel) {
    List<TopicModel> topicsList = [];

    if (testDetailModel.introduce.id != 0) {
      topicsList.add(testDetailModel.introduce);
    }

    if (testDetailModel.part1.isNotEmpty) {
      topicsList.addAll(testDetailModel.part1);
    }

    if (testDetailModel.part2 != TopicModel()) {
      topicsList.add(testDetailModel.part2);
    }

    if (testDetailModel.part3 != TopicModel()) {
      topicsList.add(testDetailModel.part3);
    }

    topicsList.sort((a, b) => a.numPart.compareTo(b.numPart));

    return topicsList;
  }

  List<PlayListModel> getPlayList(TestDetailModel testDetailModel) {
    List<PlayListModel> playList = [];
    List<TopicModel> topicsList = getListTopicModel(testDetailModel);

    for (int i = 0; i < topicsList.length; i++) {
      TopicModel topic = topicsList.elementAt(i);

      List<QuestionTopicModel> questions = getAllQuestionsTopic(topic);

      if (topic.files.isNotEmpty && topic.questionList.isNotEmpty) {
        PlayListModel playListIntro = PlayListModel();
        playListIntro.questionContent = PlayListType.introduce.name;
        playListIntro.numPart = topic.numPart;
        playListIntro.fileIntro =
            topic.files.isNotEmpty ? topic.files.first.url : "";
        playList.add(playListIntro);
      }

      for (int j = 0; j < questions.length; j++) {
        print('topic numpart : ${topic.numPart.toString()}');
        PlayListModel playListModel = PlayListModel();
        playListModel.numPart = topic.numPart;
        playListModel.endOfTakeNote = topic.endOfTakeNote.url;
        playListModel.endOfTest = topic.fileEndOfTest.url;
        QuestionTopicModel question = questions.elementAt(j);
        question.numPart = topic.numPart;
        playListModel.questionContent = question.content;
        playListModel.cueCard = question.cueCard;
        playListModel.isFollowUp = question.isFollowUpQuestion();
        List<FileTopicModel> files = question.files;
        playListModel.questionTopicModel = question;
        playListModel.fileQuestionNormal = files.first.url;
        playListModel.fileQuestionSlow = files.length > 1
            ? files.last.url
            : playListModel.fileQuestionNormal;
        playList.add(playListModel);
      }

      if (topic.endOfTakeNote.url.isNotEmpty && topic.questionList.isNotEmpty) {
        PlayListModel playListEndOfTakeNote = PlayListModel();
        playListEndOfTakeNote.endOfTakeNote = topic.endOfTakeNote.url;
        playListEndOfTakeNote.questionContent = PlayListType.endOfTakeNote.name;
        playListEndOfTakeNote.numPart = 2;
        playList.add(playListEndOfTakeNote);
      }

      if (topic.fileEndOfTest.url.isNotEmpty) {
        PlayListModel playListEndOfTest = PlayListModel();
        playListEndOfTest.endOfTest = topic.fileEndOfTest.url;
        playListEndOfTest.questionContent = PlayListType.endOfTest.name;
        playListEndOfTest.numPart = 3;
        playList.add(playListEndOfTest);
      }
    }

    playList.sort((a, b) => a.numPart.compareTo(b.numPart));

    return playList;
  }

  List<QuestionTopicModel> getAllQuestionsTopic(TopicModel topicModel) {
    List<QuestionTopicModel> questions = [];
    if (topicModel.followUp.isNotEmpty) {
      questions.addAll(topicModel.followUp);
    }
    questions.addAll(topicModel.questionList);
    return questions;
  }

  int getQuestionLength(TestDetailModel testDetailModel) {
    List<TopicModel> topics = getListTopicModel(testDetailModel);
    List<QuestionTopicModel> questions = [];
    for (int i = 0; i < topics.length; i++) {
      questions.addAll(getAllQuestionsTopic(topics[i]));
    }
    return questions.length;
  }

  Future playingIntroduce(String file) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      print("Handle have not file introduce 1");
    }
  }

  Future playingQuestion(String fileNormal, String fileSlow) async {
    bool isExistFileNormal = await FileStorageHelper.checkExistFile(
        fileNormal, MediaType.video, null);
    bool isExistFileSlow =
        await FileStorageHelper.checkExistFile(fileSlow, MediaType.video, null);

    if (isExistFileNormal) {
      String normalPath = await FileStorageHelper.getFilePath(
          fileNormal, MediaType.video, null);

      String slowPath = isExistFileSlow
          ? await FileStorageHelper.getFilePath(fileSlow, MediaType.video, null)
          : normalPath;
      _view!.playFileVideo(File(normalPath), File(slowPath));
    } else {
      //Handle have not file question
    }
  }

  Future playingEndOfTakeNote(String file) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      print("Handle have not file introduce 1");
    }
  }

  Future playingEndOfTest(String file) async {
    bool isExist =
        await FileStorageHelper.checkExistFile(file, MediaType.video, null);
    if (isExist) {
      String filePath =
          await FileStorageHelper.getFilePath(file, MediaType.video, null);
      _view!.playFileVideo(File(filePath), File(""));
    } else {
      //Handle have not file introduce
      print("Handle have not file introduce 1");
    }
  }

  Timer startCountDown(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Timer startCountDownForCueCard(
      {required BuildContext context,
      required int count,
      required bool isPart2}) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      _view!.onCountDownForCueCard("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _view!.onFinishAnswer(isPart2);
      }
    });
  }

  Future submitMyTest(
      {required String testId,
      required String activityId,
      required List<QuestionTopicModel> questionsList}) async {
    assert(_view != null && _repository != null);

    http.MultipartRequest multiRequest = await Utils.instance()
        .formDataRequestSubmit(
            testId: testId,
            activityId: activityId,
            questions: questionsList,
            isUpdate: false);
    try {
      _repository!.submitTest(multiRequest).then((value) {
        Map<String, dynamic> json = jsonDecode(value) ?? {};
        if (kDebugMode) {
          print("DEBUG: error form: ${json.toString()}");
        }
        if (json['error_code'] == 200) {
          _view!.submitAnswersSuccess(AlertClass.submitTestSuccess);
        } else {
          _view!.submitAnswerFail(AlertClass.failToSubmitAndContactAdmin);
        }
      }).catchError((onError) {
        if (kDebugMode) {
          print('catchError updateAnswerFail ${onError.toString()}');
        }
        _view!.submitAnswerFail(AlertClass.failToSubmitAndContactAdmin);
      });
    } on TimeoutException {
      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    } on SocketException {
      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    } on http.ClientException {
      _view!.submitAnswerFail(AlertClass.networkFailToSubmit);
    }
  }
}
