import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:video_player/video_player.dart';

import '../data_source/constants.dart';
import '../models/my_test_models/result_response_model.dart';
import '../models/my_test_models/student_result_model.dart';
import '../models/simulator_test_models/playlist_model.dart';
import '../models/simulator_test_models/test_detail_model.dart';

class MyTestProvider extends ChangeNotifier {
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

  bool _isGettingTestDetail = true;
  bool get isGettingTestDetail => _isGettingTestDetail;
  void setGettingTestDetailStatus(bool isProcessing) {
    _isGettingTestDetail = isProcessing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isDownloadProgressing = false;
  bool get isDownloadProgressing => _isDownloadProgressing;
  void setDownloadProgressingStatus(bool isDownloading) {
    _isDownloadProgressing = isDownloading;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<QuestionTopicModel> _questions = [];
  List<QuestionTopicModel> get questionsList => _questions;
  void setQuestionsList(List<QuestionTopicModel> questions) {
    _questions = questions;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<QuestionTopicModel> _reAnswerQuestions = [];
  List<QuestionTopicModel> get reAnswerQuestions => _reAnswerQuestions;
  void addReanswerQuestion(QuestionTopicModel question) {
    _reAnswerQuestions.add(question);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearReanswerQuestion() {
    _reAnswerQuestions.clear();
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

  ResultResponseModel _responseModel = ResultResponseModel();
  ResultResponseModel get responseModel => _responseModel;
  void setResultResponseModel(ResultResponseModel responseModel) {
    _responseModel = responseModel;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _playAudioExample = true;
  bool get playAudioExample => _playAudioExample;

  void setPlayAudioExample(bool visible) {
    _playAudioExample = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  /////////////////////////Download Data ///////////////////////////////////////

  int _total = 0;
  int get total => _total;
  void setTotal(int total) {
    _total = total;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _downloadingIndex = 1;
  int get downloadingIndex => _downloadingIndex;
  void updateDownloadingIndex(int index) {
    _downloadingIndex = index;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  double _downloadingPercent = 0.0;
  double get downloadingPercent => _downloadingPercent;
  void updateDownloadingPercent(double percent) {
    _downloadingPercent = percent;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _permissionDeniedTime = 0;
  int get permissionDeniedTime => _permissionDeniedTime;
  void setPermissionDeniedTime() {
    _permissionDeniedTime++;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _needDownloadAgain = false;
  bool get needDownloadAgain => _needDownloadAgain;
  void setNeedDownloadAgain(bool need) {
    _needDownloadAgain = need;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  TestDetailModel _currentTestDetail = TestDetailModel();
  TestDetailModel get currentTestDetail => _currentTestDetail;
  void setCurrentTestDetail(TestDetailModel testDetailModel) {
    _currentTestDetail = testDetailModel;
  }

  String _activityType = '';
  String get activityType => _activityType;
  void setActivityType(String type) {
    _activityType = type;
  }

  bool _dialogShowing = false;
  bool get dialogShowing => _dialogShowing;
  void setDialogShowing(bool isShowing) {
    _dialogShowing = isShowing;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Status of doing the test
  DoingStatus _doingStatus = DoingStatus.none;
  DoingStatus get doingStatus => _doingStatus;
  void updateDoingStatus(DoingStatus status) {
    _doingStatus = status;

    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<StudentResultModel> _highLightHomeWorks = [];
  List<StudentResultModel> get highLightHomeworks => _highLightHomeWorks;
  void setHighLightHomeworks(List<StudentResultModel> homeworks) {
    _highLightHomeWorks = homeworks;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<StudentResultModel> _otherLightHomeWorks = [];
  List<StudentResultModel> get otherLightHomeWorks => _otherLightHomeWorks;
  void setOtherLightHomeWorks(List<StudentResultModel> homeworks) {
    _otherLightHomeWorks = homeworks;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Video my test
  VideoPlayerController? _videoPlayerController;
  VideoPlayerController get videoPlayController =>
      _videoPlayerController ?? VideoPlayerController.networkUrl(Uri.parse(""));
  void setPlayController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
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

  VideoStatus _videoStatus = VideoStatus.start;
  VideoStatus get videoStatus => _videoStatus;
  void setVideoStatus(VideoStatus videoStatus) {
    _videoStatus = videoStatus;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _hideBlur = false;
  bool get hideBlur => _hideBlur;
  void setHideBlur(bool isHide) {
    _hideBlur = isHide;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<PlayListModel> _playList = [];
  List<PlayListModel> get playList => _playList;
  void setPlayList(List<PlayListModel> playList) {
    if (_playList.isNotEmpty) {
      _playList.clear();
    }
    _playList.addAll(playList);
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

  bool _showCueCard = false;
  bool get showCueCard => _showCueCard;
  void setShowCueCard(bool isShow) {
    _showCueCard = isShow;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _showAnswerWave = false;
  bool get showAnswerWave => _showAnswerWave;
  void setShowAnswerWave(bool isShow) {
    _showAnswerWave = isShow;
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

  int _repeatTimes = 0;
  int get repeatTimes => _repeatTimes;
  void setRepeatTimes(int time) {
    _repeatTimes = time;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearData() {
    _reAnswerQuestions.clear();
    _otherLightHomeWorks.clear();
    _highLightHomeWorks.clear();
    _dialogShowing = false;
    _doingStatus = DoingStatus.none;
    _activityType = '';
    _currentTestDetail = TestDetailModel();
    _needDownloadAgain = false;
    _permissionDeniedTime = 0;
    _downloadingPercent = 0.0;
    _downloadingIndex = 1;
    _total = 0;
    _playAudioExample = true;
    _responseModel = ResultResponseModel();
    _isDownloadProgressing = false;
    _questions.clear();
    _isPlaying = false;
    _selectedQuestionIndex = -1;
    _isGettingTestDetail = true;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
