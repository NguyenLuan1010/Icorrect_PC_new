import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/views/screens/auth/login_screen.dart';

class AuthWidgetProvider extends ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
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

  Widget _currentScreen = const LoginWidget();
  Widget get currentScreen => _currentScreen;
  void setCurrentScreen(Widget current) {
    _currentScreen = current;
    notifyListeners();
  }

  void updateProcessingStatus() {
    _isProcessing = !_isProcessing;
    notifyListeners();
  }

  bool _isRecordAnswer = false;
  bool get isRecordAnswer => _isRecordAnswer;
  void setRecordAnswer(bool record) {
    _isRecordAnswer = record;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Queue<GlobalKey<ScaffoldState>> _scaffoldKeys = Queue();
  Queue<GlobalKey<ScaffoldState>> get scaffoldKeys => _scaffoldKeys;
  void setQueueScaffoldKeys(GlobalKey<ScaffoldState> key,
      {Queue<GlobalKey<ScaffoldState>>? scaffoldKeys}) {
    _scaffoldKeys.addFirst(key);
    if (scaffoldKeys != null) {
      _scaffoldKeys.clear();
      _scaffoldKeys.addAll(scaffoldKeys);
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  GlobalKey<ScaffoldState> _globalScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get globalScaffoldKey => _globalScaffoldKey;
  void setGlobalScaffoldKey(GlobalKey<ScaffoldState> key) {
    _globalScaffoldKey = key;
    setQueueScaffoldKeys(key);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _isShowDialog = false;
  bool get isShowDialog => _isShowDialog;
  void setShowDialogWithGlobalScaffoldKey(
      bool isShowing, GlobalKey<ScaffoldState> key) {
    _isShowDialog = isShowing;
    setGlobalScaffoldKey(key);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  String _previousAction = "";
  String get previousAction => _previousAction;
  void setPreviousAction(String action) {
    _previousAction = action;
  }

  void resetPreviousAction() {
    _previousAction = "";
  }

  VideoStatus _videoStatus = VideoStatus.start;
  VideoStatus get videoStatus => _videoStatus;
  void setVideoStatus(VideoStatus videoStatus) {
    _videoStatus = videoStatus;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<dynamic> _myGridList = [];
  List<dynamic> get myGridList => _myGridList;
  void setMyGrid(dynamic item) {
    _myGridList.add(item);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<dynamic> _gridList1 = [];
  List<dynamic> _gridList2 = [];

  List<dynamic> get getGridList1 => _gridList1;
  List<dynamic> get getGridList2 => _gridList2;

  void setGridList1(dynamic item) {
    _gridList1.add(item);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setGridList2(dynamic item) {
    _gridList2.add(item);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearMyGrid() {
    _gridList1 = [];
    _gridList2 = [];
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
