import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/models/user_authentication/user_authentication_detail.dart';
import 'package:video_player/video_player.dart';

class UserAuthDetailProvider extends ChangeNotifier {
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
    _startGetUserAuthDetail = false;
    _userAuthenDetailModel = UserAuthenDetailModel();
   // _chewieController = null;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  bool _startGetUserAuthDetail = false;
  bool get startGetUserAuthDetail => _startGetUserAuthDetail;
  void setStartGetUserAuthDetail(bool isStart) {
    _startGetUserAuthDetail = isStart;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  UserAuthenDetailModel _userAuthenDetailModel = UserAuthenDetailModel();
  UserAuthenDetailModel get userAuthenDetailModel => _userAuthenDetailModel;
  void setUserAuthenModel(UserAuthenDetailModel model) {
    _userAuthenDetailModel = model;
    if (!isDisposed) {
      notifyListeners();
    }
  }

}
