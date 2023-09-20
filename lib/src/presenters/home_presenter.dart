import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/auth_repository.dart';
import '../data_source/repositories/homework_repository.dart';
import '../models/homework_models/class_model.dart';
import '../models/homework_models/homework_model.dart';
import '../models/homework_models/new_api_135/activities_model.dart';
import '../models/homework_models/new_api_135/new_class_model.dart';
import '../models/user_data_models/user_data_model.dart';
import '../utils/utils.dart';

abstract class HomeWorkViewContract {
  void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
      List<NewClassModel> classes, String currentTime);
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
      _view!.onGetListHomeworkError("Loading list homework error");
      return;
    }

    _view!.onUpdateCurrentUserInfo(currentUser);

    String email = currentUser.userInfoModel.email;
    String status = Status.allHomework.get.toString();

    _homeWorkRepository!.getHomeWorks(email, status).then((value) async {
      Map<String, dynamic> dataMap = jsonDecode(value);
      if (kDebugMode) {
        print(jsonEncode(dataMap).toString());
      }
      if (dataMap['error_code'] == 200) {
        List<NewClassModel> classes =
            await _generateListNewClass(dataMap['data']);
        List<ActivitiesModel> homeworks = await _generateListHomeWork(classes);
        _view!.onGetListHomeworkComplete(
            homeworks, classes, dataMap['current_time']);
      } else {
        _view!.onGetListHomeworkError(
            "Loading list homework error: ${dataMap['error_code']}${dataMap['status']}");
      }
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onGetListHomeworkError(onError.toString()),
    );
  }

  Future<List<NewClassModel>> _generateListNewClass(List<dynamic> data) async {
    List<NewClassModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel item = NewClassModel.fromJson(data[i]);
      temp.add(item);
    }
    return temp;
  }

  List<ActivitiesModel> filterActivities(int classSelectedId,
      List<ActivitiesModel> activities, String currentTime, String status) {
    List<ActivitiesModel> activitiesFilter = [];

    if (classSelectedId == 0 && status == "All") {
      return activities;
    }

    for (ActivitiesModel activity in activities) {
      Map<String, dynamic> activityStatus =
          Utils.instance().getHomeWorkStatus(activity, currentTime);
      if (activityStatus['title'] == status &&
          activity.classId == classSelectedId) {
        activitiesFilter.add(activity);
      } else if (classSelectedId == 0 && activityStatus['title'] == status) {
        activitiesFilter.add(activity);
      } else if (activity.classId == classSelectedId && status == "All") {
        activitiesFilter.add(activity);
      }
    }
    return activitiesFilter;
  }

  Future<List<ActivitiesModel>> _generateListHomeWork(
      List<NewClassModel> data) async {
    List<ActivitiesModel> temp = [];
    for (int i = 0; i < data.length; i++) {
      NewClassModel classModel = data[i];
      temp.addAll(classModel.activities);
    }
    return temp;
  }

  void logout() {
    assert(_view != null && _authRepository != null);

    _authRepository!.logout().then((value) async {
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
    }).catchError(
      // ignore: invalid_return_type_for_catch_error
      (onError) => _view!.onLogoutError(onError.toString()),
    );
  }
}
