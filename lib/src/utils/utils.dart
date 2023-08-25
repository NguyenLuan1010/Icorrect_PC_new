import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../models/homework_models/homework_model.dart';
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

  String getPartOfTest(int option) {
    switch (option) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'II&III';
      case 5:
        return 'FULL';
      case 6:
        return 'I&II';
      default:
        return 'NULL';
    }
  }

  Map<String, dynamic> getHomeWorkStatus(HomeWorkModel homeWorkModel) {
    switch (homeWorkModel.completeStatus) {
      case 1:
        return {
          'title': 'Submitted',
          'color': const Color.fromARGB(255, 45, 117, 243)
        };
      case 2:
        return {
          'title': 'Corrected',
          'color': const Color.fromARGB(255, 12, 201, 110)
        };
      case 0:
        return {
          'title': 'Not Completed',
          'color': const Color.fromARGB(255, 237, 179, 3)
        };
      case -1:
        return {'title': 'Late', 'color': Colors.orange};
      case -2:
        return {'title': 'Out of date', 'color': Colors.red};
      default:
        return {};
    }
  }

  String haveAiResponse(HomeWorkModel homeWorkModel) {
    return (homeWorkModel.haveAiReponse == Status.TRUE.get)
        ? '& AI Scored'
        : '';
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
}
