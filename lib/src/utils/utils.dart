import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../models/homework_models/homework_model.dart';
import '../models/homework_models/new_api_135/activities_model.dart';
import '../models/user_data_models/user_data_model.dart';
import 'define_object.dart';

class Utils {
  Utils._();
  static final Utils _utils = Utils._();
  factory Utils.instance() => _utils;

  Future<String> getDeviceIdentifier() async {
    String deviceIdentifier = "unknown";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isLinux) {
      LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      deviceIdentifier = linuxInfo.machineId ?? "unknown";
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      deviceIdentifier = macOsDeviceInfo.systemGUID ?? "unknown";
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      deviceIdentifier = windowsDeviceInfo.deviceId;
    }
    return deviceIdentifier;
  }

  Future<String> getOS() async {
    String os = "unknown";

    if (Platform.isAndroid) {
      os = "android";
    } else if (Platform.isIOS) {
      os = "ios";
    } else if (kIsWeb) {
      os = "web";
    } else if (Platform.isLinux) {
      os = "linux";
    } else if (Platform.isMacOS) {
      os = "macos";
    } else if (Platform.isWindows) {
      os = "window";
    }
    return os;
  }

  String getPartOfTestWithString(String option) {
    switch (option) {
      case 'part1':
        return 'I';
      case 'part2':
        return 'II';
      case "part3":
        return 'III';
      case "part23":
        return 'II&III';
      case 'full':
        return 'FULL';
      case "part12":
        return 'I&II';
      default:
        return 'NULL';
    }
  }

    Map<String, dynamic> getHomeWorkStatus(ActivitiesModel homeWorkModel) {
    if (null == homeWorkModel.activityAnswer) {
      //TODO: Check time end so voi time hien tai
      //Can server tra ve time hien tai - de thong nhat, do phai check timezone
      //End time > time hien tai ==> out of date
      //End time < time hien tai ==> Not Complete
      return {
        'title': 'Not Completed',
        'color': const Color.fromARGB(255, 237, 179, 3)
      };
    } else {
      if (homeWorkModel.activityAnswer!.aiOrder != 0 ||
          homeWorkModel.activityAnswer!.orderId != 0) {
        return {
          'title': 'Corrected',
          'color': const Color.fromARGB(255, 12, 201, 110)
        };
      } else {
        if (homeWorkModel.activityAnswer!.late == 0) {
          return {
            'title': 'Submitted',
            'color': const Color.fromARGB(255, 45, 117, 243)
          };
        }

        if (homeWorkModel.activityAnswer!.late == 1) {
          return {
            'title': 'Late',
            'color': Colors.orange,
          };
        }

        if (homeWorkModel.activityEndTime.isNotEmpty) {
          DateTime endTime = DateTime.parse(homeWorkModel.activityEndTime);
          DateTime createTime =
              DateTime.parse(homeWorkModel.activityAnswer!.createdAt);
          if (endTime.compareTo(createTime) < 0) {
            return {
              'title': 'Out of date',
              'color': Colors.red,
            };
          }
        }
      }

      return {}; //Error
    }
  }

   String haveAiResponse(ActivitiesModel homeWorkModel) {
    if (null != homeWorkModel.activityAnswer) {
      if (homeWorkModel.activityAnswer!.aiOrder != 0) {
        return "& AI Scored";
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  int getFilterStatus(String status) {
    switch (status) {
      case 'Submitted':
        return 1;
      case 'Corrected':
        return 2;
      case 'Not Completed':
        return 0;
      case 'Late':
        return -1;
      case 'Out of date':
        return -2;
      default:
        return -10;
    }
  }

  void setAppVersion(String version) {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.appVersion, value: version);
  }

  Future<String> getAppVersion() {
    return AppSharedPref.instance().getString(key: AppSharedKeys.appVersion);
  }

  void setCurrentUser(UserDataModel user) {
    AppSharedPref.instance().putString(
        key: AppSharedKeys.currentUser,
        value: jsonEncode(user ?? UserDataModel().toJson()));
  }

  void clearCurrentUser() {
    AppSharedPref.instance()
        .putString(key: AppSharedKeys.currentUser, value: null);
  }

  Future<String> getAccessToken() {
    return AppSharedPref.instance().getString(key: AppSharedKeys.apiToken);
  }

  void setAccessToken(String token) {
    return AppSharedPref.instance()
        .putString(key: AppSharedKeys.apiToken, value: token);
  }

  void setCookiesTime(String saveTime) {
    return AppSharedPref.instance()
        .putString(key: AppSharedKeys.saveTime, value: saveTime);
  }

  Future<String?> getCookiesTime() {
    return AppSharedPref.instance().getString(key: AppSharedKeys.saveTime);
  }

  Future<UserDataModel?> getCurrentUser() async {
    String userJson = await AppSharedPref.instance()
            .getString(key: AppSharedKeys.currentUser) ??
        '';
    if (userJson.isEmpty) {
      return null;
    }

    Map<String, dynamic> userMap = jsonDecode(userJson) ?? {};
    if (userMap.isEmpty) {
      return null;
    }
    return UserDataModel.fromJson(userMap);
  }

  String convertFileName(String nameFile) {
    String letter = '/';
    String newLetter = '-';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

   String reConvertFileName(String nameFile) {
    String letter = '-';
    String newLetter = '/';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

}
