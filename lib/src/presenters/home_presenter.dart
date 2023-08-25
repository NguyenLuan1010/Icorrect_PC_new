import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/auth_repository.dart';
import '../data_source/repositories/homework_repository.dart';
import '../models/homework_models/class_model.dart';
import '../models/homework_models/homework_model.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';

abstract class HomeWorkViewContract {
  void onGetListHomeworkComplete(
      List<HomeWorkModel> homeworks, List<ClassModel> classes);
  void onGetListHomeworkError(String message);
  void onLogoutComplete();
  void onLogoutError(String message);
  void onUpdateCurrentUserInfo(UserDataModel userDataModel);
}

class HomeWorkPresenter {
  final HomeWorkViewContract? _view;
  AuthRepository? _authRepository;
  HomeWorkRepository? _homeWorkRepository;

  HomeWorkPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
    _homeWorkRepository = Injector().getHomeWorkRepository();
  }

  void getListHomeWork() async {
    assert(_view != null && _homeWorkRepository != null);

    UserDataModel? currentUser = await Utils.instance().getCurrentUser();
    if (currentUser == null) {
      if (kDebugMode) {
        print(
            "HomeCubit/getLessons: loading current user's information error!");
      }
      _view!.onGetListHomeworkError("Loading list homework error");
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;

    _homeWorkRepository!.getHomeWorks(email).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        List<HomeWorkModel> homeworks =
            await _generateListHomeWork(dataMap['result']);
        List<ClassModel> classes = await _generateListClass(dataMap['classes']);
        _view!.onGetListHomeworkComplete(homeworks, classes);
      } else {
        _view!.onGetListHomeworkError(
            "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      (onError) => _view!.onGetListHomeworkError(onError.toString()),
    );
  }

  Future<List<HomeWorkModel>> _generateListHomeWork(List<dynamic> data) async {
    List<HomeWorkModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      HomeWorkModel item = HomeWorkModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  Future<List<ClassModel>> _generateListClass(List<dynamic> data) async {
    List<ClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      ClassModel item = ClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  void logout() {
    assert(_view != null && _authRepository != null);

    _authRepository!.logout().then((value) async {
      // //Delete access token
      // cubit.deleteAccessToken();
      //
      // //Delete Filter
      // cubit.deleteFilter();
      //
      // //Goto Login Screen
      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => const Login()));
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (dataMap['error_code'] == 200) {
        //Delete access token
        Utils.instance().setAccessToken('');

        //Delete current user
        Utils.instance().clearCurrentUser();

        _view!.onLogoutComplete();
      } else {
        _view!.onLogoutError(
            "Logout error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError((onError) => _view!.onLogoutError(onError.toString()));
  }
}
