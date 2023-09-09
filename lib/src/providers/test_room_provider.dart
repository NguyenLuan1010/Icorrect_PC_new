import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/utils/define_object.dart';
import 'package:video_player/video_player.dart';

class TestRoomProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  void clearData() {
    _strCountCueCard = "";
    _currentQuestion = QuestionTopicModel();
    _currentQuestionList.clear();
    _isVisibleCueCard = false;
    _isVisibleSaveTheTest = false;
    _isStartTest = false;
    _videoPlayerController = VideoPlayerController.file(File(""))..initialize();
    _visibleRecord = false;
    _enableRepeatButton = true;
    _strCountCueCard = "";
    _strCountDown = "";
    if (!isDisposed) {
      notifyListeners();
    }
  }

  HandleWhenFinish _handleWhenFinish = HandleWhenFinish.introVideoType;
  HandleWhenFinish get handleWhenFinish => _handleWhenFinish;
  void setHandleWhenFinish(HandleWhenFinish handle) {
    _handleWhenFinish = handle;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _visibleRecord = false;
  bool get visibleRecord => _visibleRecord;
  void setVisibleRecord(bool visible) {
    _visibleRecord = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _enableRepeatButton = true;
  bool get enableRepeatButton => _enableRepeatButton;
  void setEnableRepeatButton(bool enable) {
    _enableRepeatButton = enable;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCountCueCard = "";
  String get strCountCueCard => _strCountCueCard;
  void setStrCountCueCard(String count) {
    _strCountCueCard = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _strCountDown = "";
  String get strCountDown => _strCountDown;
  void setStrCountDown(String count) {
    _strCountDown = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  QuestionTopicModel _currentQuestion = QuestionTopicModel();
  int _indexCurrentQuestion = 0;
  QuestionTopicModel get currentQuestion => _currentQuestion;
  int get indexCurrentQuestion => _indexCurrentQuestion;
  void setCurrentQuestion(int index, QuestionTopicModel question) {
    _currentQuestion = question;
    _indexCurrentQuestion = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<QuestionTopicModel> _currentQuestionList = [];
  List<QuestionTopicModel> get currentQuestionList => _currentQuestionList;
  void setCurrentQuestionList(List<QuestionTopicModel> questions) {
    if (_currentQuestionList.isNotEmpty) {
      _currentQuestionList.clear();
    }
    _currentQuestionList.addAll(questions);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Queue<TopicModel> _topicsQueue = Queue();
  Queue<TopicModel> get topicQueue => _topicsQueue;
  void setTopicModelQueue(Queue<TopicModel> topicsQueue) {
    if (_topicsQueue.isNotEmpty) {
      _topicsQueue.clear();
    }
    _topicsQueue.addAll(topicsQueue);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  TopicModel _currentTopic = TopicModel();
  TopicModel get currentTopic => _currentTopic;
  void setCurrentTopic(TopicModel currentTopic) {
    _currentTopic = currentTopic;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleCueCard = false;
  bool get isVisibleCueCard => _isVisibleCueCard;
  void setVisibleCueCard(bool visible) {
    _isVisibleCueCard = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isVisibleSaveTheTest = false;
  bool get isVisibleSaveTheTest => _isVisibleSaveTheTest;
  void setVisibleSaveTheTest(bool visible) {
    _isVisibleSaveTheTest = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isStartTest = false;
  bool get isStartTest => _isStartTest;
  void setStartTest(bool status) {
    _isStartTest = status;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  VideoPlayerController? _videoPlayerController;
  VideoPlayerController get videoPlayController =>
      _videoPlayerController ?? VideoPlayerController.networkUrl(Uri.parse(""));
  void setPlayController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
