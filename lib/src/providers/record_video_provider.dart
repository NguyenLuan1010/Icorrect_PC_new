import 'dart:io';

import 'package:flutter/material.dart';

class RecordVideoProvider extends ChangeNotifier {
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

  File _videoRecorded = File('');
  File get videoRecorded => _videoRecorded;
  void setVideoRecord(File savedFile) {
    _videoRecorded = savedFile;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _showWarning = false;
  bool get showWarning => _showWarning;
  void setShowWarning(bool isShow) {
    _showWarning = isShow;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _title = '';
  String _content = '';
  String _cancelButtonName = '';
  String _okButtonName = '';
  Function _cancelAction = () {};
  Function _okAction = () {};
  bool _isWarningConfirm = false;

  String get title => _title;
  String get content => _content;
  String get cancelButtonName => _cancelButtonName;
  String get okButtonName => _okButtonName;
  Function get cancelAction => _cancelAction;
  Function get okAction => _okAction;
  bool get isWarningConfirm => _isWarningConfirm;

  void showWarningStatus(
      {required String title,
      required String content,
      required Function cancelAction,
      required Function okAction,
      required bool isWaring,
      String? cancelButtonName,
      String? okButtonName}) {
    _title = title;
    _content = content;
    _cancelButtonName = cancelButtonName ?? 'Cancel';
    _okButtonName = okButtonName ?? 'Confirm';
    _cancelAction = cancelAction;
    _okAction = okAction;
    _isWarningConfirm = isWaring;
    _showWarning = true;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Duration _currentDuration = Duration.zero;
  String _strCount = '00:00';
  Duration get currentDuration => _currentDuration;
  String get strCount => _strCount;
  void setCurrentDuration(Duration duration, String strCount) {
    _currentDuration = duration;
    _strCount = strCount;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
