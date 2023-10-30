import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/ui_models/user_authen_status.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/views/dialogs/custom_alert_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data_source/api_urls.dart';
import '../data_source/constants.dart';
import '../data_source/local/app_shared_preferences_keys.dart';
import '../data_source/local/app_shared_references.dart';
import '../data_source/local/file_storage_helper.dart';
import '../models/homework_models/homework_model.dart';
import '../models/homework_models/new_api_135/activities_model.dart';
import '../models/homework_models/new_api_135/new_class_model.dart';
import '../models/log_models/log_model.dart';
import '../models/my_test_models/student_result_model.dart';
import '../models/simulator_test_models/question_topic_model.dart';
import '../models/user_data_models/user_data_model.dart';
import 'package:http/http.dart' as http;

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

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) {
        return '$n';
      }
      return '0$n';
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Map<String, dynamic> getHomeWorkStatus(
      ActivitiesModel homeWorkModel, String serverCurrentTime) {
    if (null == homeWorkModel.activityAnswer) {
      bool timeCheck =
          isExpired(homeWorkModel.activityEndTime, serverCurrentTime);
      if (timeCheck) {
        return {
          'title': 'Out of date',
          'color': Colors.red,
        };
      }

      return {
        'title': 'Not Completed',
        'color': const Color.fromARGB(255, 237, 179, 3)
      };
    } else {
      if (homeWorkModel.activityAnswer!.orderId != 0) {
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

  bool isExpired(String activityEndTime, String serverCurrentTime) {
    final t1 = DateTime.parse(activityEndTime);

    var inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    var inputDate = inputFormat.parse(serverCurrentTime);
    var outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final t2 = DateTime.parse(outputFormat.format(inputDate));
    if (t1.compareTo(t2) < 0) {
      return true;
    } else {
      return false;
    }
  }

  String haveAiResponse(ActivitiesModel homeWorkModel) {
    if (null != homeWorkModel.activityAnswer) {
      if (homeWorkModel.activityAnswer!.aiOrder != 0) {
        return " AI Scored";
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

  Map<String, dynamic> scoreReponse(StudentResultModel resultModel) {
    if (resultModel.overallScore.isNotEmpty &&
        resultModel.overallScore != "0.0") {
      return {'color': Colors.green, 'score': resultModel.overallScore};
    } else {
      String aiScore = resultModel.aiScore;
      if (aiScore.isNotEmpty) {
        if (isNumeric(aiScore) &&
            (double.parse(aiScore) == -1.0 || double.parse(aiScore) == -2.0)) {
          return {'color': Colors.red, 'score': 'Not Evaluated'};
        } else {
          return {'color': Colors.blue, 'score': aiScore};
        }
      } else {
        return {'color': Colors.red, 'score': 'Not Evaluated'};
      }
    }
  }

  bool isNumeric(String str) {
    try {
      var value = double.parse(str);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
  }

   UserAuthenStatusUI getUserAuthenStatus(int status) {
    switch (status) {
      case 0:
        return UserAuthenStatusUI(
            title: StringConstants.not_auth_title,
            description: StringConstants.not_auth_content,
            icon: Icons.cancel_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 4:
        return UserAuthenStatusUI(
            title: StringConstants.reject_auth_title,
            description: StringConstants.reject_auth_content,
            icon: Icons.video_camera_front_outlined,
            backgroundColor: const Color.fromARGB(255, 248, 233, 179),
            titleColor: Colors.amber,
            iconColor: Colors.amber);
      case 1:
        return UserAuthenStatusUI(
            title: StringConstants.user_authed_title,
            description: StringConstants.user_authed_content,
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: const Color.fromARGB(255, 179, 248, 195),
            titleColor: Colors.green,
            iconColor: Colors.green);
      case 3:
        return UserAuthenStatusUI(
            title: StringConstants.progress_auth_title,
            description: StringConstants.progress_auth_content,
            icon: Icons.change_circle_sharp,
            backgroundColor: const Color.fromARGB(255, 179, 222, 248),
            titleColor: Colors.blue,
            iconColor: Colors.blue);
      case 2:
        return UserAuthenStatusUI(
            title: StringConstants.lock_auth_title,
            description: StringConstants.lock_auth_content,
            icon: Icons.lock,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
      case 99:
      default:
        return UserAuthenStatusUI(
            title: StringConstants.error_auth_title,
            description: StringConstants.error_auth_content,
            icon: Icons.error_outline,
            backgroundColor: const Color.fromARGB(255, 248, 179, 179),
            titleColor: Colors.red,
            iconColor: Colors.red);
    }
  }


  String convertFileName(String nameFile) {
    String letter = '/';
    String newLetter = '_slash_';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

  String reConvertFileName(String nameFile) {
    String letter = '_slash_';
    String newLetter = '/';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

  String fileType(String filePath) {
    String fileExtension = filePath.split('.').last.toLowerCase();
    if (fileExtension == 'mp4' ||
        fileExtension == 'mov' ||
        fileExtension == 'avi') {
      return StringClass.video;
    }
    if (fileExtension == 'wav' ||
        fileExtension == 'mp3' ||
        fileExtension == 'aac') {
      return StringClass.audio;
    }
    return '';
  }

  Future<File> prepareVideoFile(String fileName) async {
    File decodedVideoFile;
    String bs4str =
        await FileStorageHelper.readVideoFromFile(fileName, MediaType.video);
    Uint8List decodedBytes = base64.decode(bs4str);
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.video, null);

    if (decodedBytes.isEmpty) {
      //From second time and before
      decodedVideoFile = File(filePath);
    } else {
      //Convert for first time
      decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    }
    return decodedVideoFile;
  }

  Future<File> prepareAudioFile(String fileName, String? testId) async {
    File decodedVideoFile;
    String bs4str =
        await FileStorageHelper.readVideoFromFile(fileName, MediaType.audio);
    Uint8List decodedBytes = base64.decode(bs4str);
    String filePath =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    if (decodedBytes.isEmpty) {
      decodedVideoFile = File(filePath);
    } else {
      decodedVideoFile = await File(filePath).writeAsBytes(decodedBytes);
    }
    return decodedVideoFile;
  }

  int getRecordTime(int type) {
    switch (type) {
      case 0: //Answer for question in introduce
        return 30;
      case 1: //Answer for question in part 1
        return 30;
      case 2: //Answer for question in part 2
        return 120;
      case 3: //Answer for question in part 3
        return 45;
      default:
        return 0;
    }
  }

  String getTimeRecordString(int timerCount) {
    String result = '';

    if (timerCount < 10) {
      return "00:0$timerCount";
    }

    if (timerCount < 60) {
      return "00:$timerCount";
    }

    if (timerCount > 60) {
      int seconds = (timerCount / 60).floor();
      int ms = (timerCount - seconds * 60);
      String str1 = seconds < 10 ? "0$seconds" : "$seconds";
      String str2 = ms < 10 ? '0$ms' : '$ms';
      return "$str1:$str2";
    }

    return result;
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Future<String> getAudioPathToPlay(
      QuestionTopicModel question, String? testId) async {
    String fileName = '';
    if (question.answers.length > 1) {
      if (question.repeatIndex == 0) {
        fileName = question.answers.last.url;
      } else {
        fileName = question.answers.elementAt(question.repeatIndex - 1).url;
      }
    } else {
      fileName = question.answers.first.url;
    }
    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    return path;
  }

  Future<String> generateAudioFileName() async {
    DateTime dateTime = DateTime.now();
    String timeNow =
        '${dateTime.year}${dateTime.month}${dateTime.day}_${dateTime.hour}${dateTime.minute}${dateTime.second}';

    return '${timeNow}_reanswer';
  }

  Future<String> getReviewingAudioPathToPlay(
      QuestionTopicModel question, String? testId) async {
    String fileName = question.answers.first.url;
    String path =
        await FileStorageHelper.getFilePath(fileName, MediaType.audio, testId);
    return path;
  }

  String getClassNameWithId(String id, List<NewClassModel> list) {
    if (list.isEmpty) return "";

    for (int i = 0; i < list.length; i++) {
      NewClassModel c = list[i];
      if (c.id.toString() == id) {
        return c.name;
      }
    }

    return "";
  }

  Future<http.MultipartRequest> formDataRequestSubmit(
      {required String testId,
      required String activityId,
      required List<QuestionTopicModel> questions,
      required bool isUpdate}) async {
    String url = submitHomeWorkV2EP();
    http.MultipartRequest request =
        http.MultipartRequest(RequestMethod.post, Uri.parse(url));
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${await Utils.instance().getAccessToken()}'
    });

    Map<String, String> formData = {};
    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries([MapEntry('is_update', isUpdate ? '1' : '0')]);
    formData.addEntries([MapEntry('activity_id', activityId)]);

    formData.addEntries([const MapEntry('os', "pc_flutter")]);
    formData.addEntries([const MapEntry('app_version', '2.0.2')]);
    String format = '';
    String reanswerFormat = '';
    String endFormat = '';
    for (QuestionTopicModel q in questions) {
      String questionId = q.id.toString();

      if (kDebugMode) {
        print("DEBUG: num part : ${q.numPart.toString()}");
      }
      if (q.numPart == PartOfTest.introduce.get) {
        format = 'introduce[$questionId]';
        reanswerFormat = 'reanswer_introduce[$questionId]';
      }

      if (q.type == PartOfTest.part1.get) {
        format = 'part1[$questionId]';
        reanswerFormat = 'reanswer_part1[$questionId]';
      }

      if (q.type == PartOfTest.part2.get) {
        format = 'part2[$questionId]';
        reanswerFormat = 'reanswer_part2[$questionId]';
      }

      if (q.type == PartOfTest.part3.get && !q.isFollowUpQuestion()) {
        format = 'part3[$questionId]';
        reanswerFormat = 'reanswer_part3[$questionId]';
      }
      if (q.type == PartOfTest.part3.get && q.isFollowUpQuestion()) {
        format = 'followup[$questionId]';
        reanswerFormat = 'reanswer_followup[$questionId]';
      }

      formData
          .addEntries([MapEntry(reanswerFormat, q.reAnswerCount.toString())]);

      for (int i = 0; i < q.answers.length; i++) {
        endFormat = '$format[$i]';
        File audioFile = File(await FileStorageHelper.getFilePath(
            q.answers.elementAt(i).url.toString(), MediaType.audio, testId));

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath(endFormat, audioFile.path));
        }
      }
    }

    request.fields.addAll(formData);

    return request;
  }

  double getDevicesWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getDevicesHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  String getPreviousAction(BuildContext context) {
    String previousAction = "";
    AuthWidgetProvider authProvider =
        Provider.of<AuthWidgetProvider>(context, listen: false);
    previousAction = authProvider.previousAction;
    return previousAction;
  }

  void setPreviousAction(BuildContext context, String action) {
    AuthWidgetProvider authProvider =
        Provider.of<AuthWidgetProvider>(context, listen: false);
    authProvider.setPreviousAction(action);
  }

  Future<LogModel> prepareToCreateLog(BuildContext context,
      {required String action}) async {
    String previousAction = getPreviousAction(context);
    LogModel log = await createLog(
        action: action,
        previousAction: previousAction,
        status: "",
        message: "",
        data: {});
    setPreviousAction(context, action);

    return log;
  }

  Future<void> deleteLogFile() async {
    //Check logs file is exist
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/flutter_logs.txt";
    File file = File(path);

    try {
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print("DEBUG: Delete log file success");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG: Delete log file error: ${e.toString()}");
      }
    }
  }

  int getDateTimeNow() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<String> getOSVersion() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String version = "";
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      version =
          '${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      version = iosInfo.systemVersion;
    }
    return version;
  }

  Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName = "";
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }
    return deviceName;
  }

  Future<LogModel> createLog({
    required String action,
    required String previousAction,
    required String status,
    required String message,
    required Map<String, String> data,
  }) async {
    LogModel log = LogModel();
    log.action = action;
    log.previousAction = previousAction;
    log.status = status;
    log.createdTime = getDateTimeNow();
    log.message = message;
    log.os = await getOS();
    UserDataModel? currentUser = await getCurrentUser();
    if (null == currentUser) {
      log.userId = 0;
    } else {
      log.userId = currentUser.userInfoModel.id;
    }
    log.deviceId = await getDeviceIdentifier();
    log.deviceName = await getDeviceName();
    log.osVersion = await getOSVersion();
    log.versionApp = await getAppVersion();
    log.data = data;
    return log;
  }

  void prepareLogData({
    required LogModel? log,
    required Map<String, dynamic>? data,
    required String? message,
    required String status,
  }) {
    if (null == log) return;

    if (null != data) {
      log.addData(key: "data", value: jsonEncode(data));
    }

    if (null != message) {
      log.message = message;
    }

    addLog(log, status);
  }

  void addLog(LogModel log, String status) {
    if (status != "none") {
      //NOT Action log
      DateTime createdTime =
          DateTime.fromMillisecondsSinceEpoch(log.createdTime);
      DateTime responseTime = DateTime.now();

      Duration diff = responseTime.difference(createdTime);

      if (diff.inSeconds < 1) {
        log.responseTime = 1;
      } else {
        log.responseTime = diff.inSeconds;
      }
    }
    log.status = status;

    //Convert log into string before write into file
    String logString = convertLogModelToJson(log);
    writeLogIntoFile(logString);
  }

  String convertLogModelToJson(LogModel log) {
    final String jsonString = jsonEncode(log);
    return jsonString;
  }

  void writeLogIntoFile(String logString) async {
    String folderPath = await FileStorageHelper.getExternalDocumentPath();
    String path = "$folderPath/flutter_logs.txt";
    if (kDebugMode) {
      print("DEBUG: log file path = $path");
    }
    File file;

    bool isExistFile = await File(path).exists();

    if (isExistFile) {
      file = File(path);
      await file.writeAsString("\n", mode: FileMode.append);
    } else {
      file = await File(path).create();
    }

    try {
      await file.writeAsString(logString, mode: FileMode.append);
      if (kDebugMode) {
        print("DEBUG: write log into file success");
      }
    } catch (e) {
      if (kDebugMode) {
        print("DEBUG: write log into file failed");
      }
    }
  }

  void showConnectionErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: StringConstants.dialog_title,
          description: StringConstants.network_error_message,
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  Future<bool> checkVideoFileExist(String path, MediaType mediaType) async {
    bool result = await File(path).exists();
    return result;
  }

  int getBeingOutTimeInSeconds(DateTime startTime, DateTime endTime) {
    Duration diff = endTime.difference(startTime);
    return diff.inSeconds;
  }
}
