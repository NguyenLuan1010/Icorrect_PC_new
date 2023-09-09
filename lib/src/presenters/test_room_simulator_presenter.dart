import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/local/file_storage_helper.dart';
import '../data_source/repositories/simulator_test_repository.dart';

abstract class TestRoomSimulatorContract {
  void playIntroduce(File introduceFile);
  void playQuestion(File normalFile, File slowFile);
  void onCountDown(String strCount);
  void onFinishAnswer(bool isPart2);
  void onCountDownForCueCard(String strCount);
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

  List<QuestionTopicModel> getAllQuestionsTopic(TopicModel topicModel) {
    List<QuestionTopicModel> questions = [];
    if (topicModel.followUp.isNotEmpty) {
      questions.addAll(topicModel.followUp);
    }
    questions.addAll(topicModel.questionList);
    return questions;
  }

  // Future doingTest(, TopicModel currentTopic,
  //     {QuestionTopicModel? currentQuestion}) async {
  //   if (!playedIntroduce) {
  //     playingIntroduce(currentTopic);
  //   } else {
  //     playingQuestion(currentQuestion!);
  //   }
  // }

  bool isLastTopic(TopicModel currentTopic, Queue<TopicModel> topics) {
    return currentTopic.id == topics.last.id;
  }

  bool hasFollowUp(TopicModel currentTopic) {
    return currentTopic.followUp.isNotEmpty;
  }

  Future playingIntroduce(TopicModel currentTopic) async {
    List<FileTopicModel> files = currentTopic.files;

    if (files.isNotEmpty) {
      FileTopicModel file = files.first;
      if (kDebugMode) {
        print("DEBUG: file.url.toString() : ${file.url.toString()}");
      }

      bool isExist = await FileStorageHelper.checkExistFile(
          file.url, MediaType.video, null);
      if (isExist) {
        String filePath = await FileStorageHelper.getFilePath(
            file.url, MediaType.video, null);
        _view!.playIntroduce(File(filePath));
      } else {
        //Handle have not file introduce
        print("Handle have not file introduce 1");
      }
    } else {
      //Handle have not file introduce
      print("Handle have not file introduce 2");
    }
  }

  Future playingQuestion(QuestionTopicModel currentQuestion) async {
    List<FileTopicModel> files = currentQuestion.files;
    if (files.isNotEmpty) {
      FileTopicModel fileMormal = files.first;
      FileTopicModel fileSlow = FileTopicModel();
      if (files.length == 2) {
        fileSlow = files.last;
      }

      bool isExistFileNormal = await FileStorageHelper.checkExistFile(
          fileMormal.url, MediaType.video, null);
      bool isExistFileSlow = await FileStorageHelper.checkExistFile(
          fileSlow.url, MediaType.video, null);

      if (isExistFileNormal) {
        String normalPath = await FileStorageHelper.getFilePath(
            fileMormal.url, MediaType.video, null);

        String slowPath = isExistFileSlow
            ? await FileStorageHelper.getFilePath(
                fileSlow.url, MediaType.video, null)
            : normalPath;
        _view!.playQuestion(File(normalPath), File(slowPath));
      } else {
        //Handle have not file question
      }
    } else {
      //Handle have not file question
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
}
