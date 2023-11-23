import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/file_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/playlist_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
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
    _currentCount = 1000;
    _strCountCueCard = "";
    _currentQuestion = QuestionTopicModel();
   // _questionList.clear();
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

  int _selectedQuestionIndex = -1;
  bool _isPlaying = false;
  int get selectedQuestionIndex => _selectedQuestionIndex;
  bool get isPlaying => _isPlaying;
  void setSelectedQuestionIndex(int i, bool isPlaying) {
    _selectedQuestionIndex = i;
    _isPlaying = isPlaying;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canPlayAnswer = false;
  bool get canPlayAnswer => _canPlayAnswer;
  void setCanPlayAnswer(bool canPlayAnswer) {
    _canPlayAnswer = canPlayAnswer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _canReanswer = false;
  bool get canReanswer => _canReanswer;
  void setCanReanswer(bool reanswer) {
    _canReanswer = reanswer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  File _fileImage = File("");
  File get fileImage => _fileImage;
  void setFileImage(File fileImage) {
    _fileImage = fileImage;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearImageFile() {
    _fileImage = File('');
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<FileTopicModel> _answersRecord = [];
  List<FileTopicModel> get answerRecord => _answersRecord;
  void addAnswerRecord(FileTopicModel file) {
    _answersRecord.add(file);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearAnswers() {
    if (_answersRecord.isNotEmpty) {
      _answersRecord.clear();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _playedIntroduce = false;
  bool get playedIntroduce => _playedIntroduce;
  void setPlayedIntroduce(bool played) {
    _playedIntroduce = played;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  PlayListModel _currentPlay = PlayListModel();
  PlayListModel get currentPlay => _currentPlay;
  void setCurrentPlay(PlayListModel play) {
    _currentPlay = play;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _repeatTimes = 0;
  int get repeatTimes => _repeatTimes;
  void setRepeatTimes(int time) {
    _repeatTimes = time;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexCurrentPlay = 0;
  int get indexCurrentPlay => _indexCurrentPlay;
  void setIndexCurrentPlay(int index) {
    _indexCurrentPlay = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _questionLength = 1;
  int get questionLength => _questionLength;
  void setQuestionLength(int length) {
    _questionLength = length;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _indexQuestion = 0;
  int get indexQuestion => _indexQuestion;
  void setIndexQuestion(int index) {
    _indexQuestion = index;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<PlayListModel> _playList = [];
  List<PlayListModel> get playList => _playList;
  void setPlayList(List<PlayListModel> playList) {
    _playList = playList;
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

  int _currentCount = 100;
  int get currentCount => _currentCount;
  void setCurrentCount(int count) {
    _currentCount = count;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  QuestionTopicModel _currentQuestion = QuestionTopicModel();
  QuestionTopicModel get currentQuestion => _currentQuestion;
  void setCurrentQuestion(QuestionTopicModel question) {
    _currentQuestion = question;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  // List<QuestionTopicModel> _questionList = [];
  // List<QuestionTopicModel> get questionList => _questionList;
  // void addQuestionToList(QuestionTopicModel questionTopicModel) {
  //   _questionList.add(questionTopicModel);
  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

  // void setQuestionList(List<QuestionTopicModel> questions) {
  //   if (_questionList.isNotEmpty) {
  //     _questionList.clear();
  //   }
  //   _questionList.addAll(questions);
  //   if (!isDisposed) {
  //     notifyListeners();
  //   }
  // }

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
