import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/my_test_models/result_response_model.dart';
import '../models/simulator_test_models/question_topic_model.dart';
import '../models/simulator_test_models/test_detail_model.dart';

class StudentTestProvider extends ChangeNotifier {
  bool isDisposed = false;
  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

///////////////////////////// MY TEST DETAIL/////////////////////////////
 
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

  
  String _activityType = '';
  String get activityType => _activityType;
  void setActivityType(String type) {
    _activityType = type;
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
}
