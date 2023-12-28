import 'package:flutter/foundation.dart';

import '../data_source/constants.dart';

class SubmitVideoAuthProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
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

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;
  void setIsSubmitLoading(bool isSubmit) {
    _isSubmitLoading = isSubmit;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
