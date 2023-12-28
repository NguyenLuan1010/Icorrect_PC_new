import 'dart:convert';

import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

TestDetailModel testDetailModelFromJson(String str) =>
    TestDetailModel.fromJson(json.decode(str));
String testDetailModelToJson(TestDetailModel data) =>
    json.encode(data.toJson());

class TestDetailModel {
  String? _activityType;
  int? _testOption;
  TopicModel? _introduce;
  List<TopicModel>? _part1;
  String? _domainName;
  int? _testId;
  String? _checkSum;
  TopicModel? _part2;
  TopicModel? _part3;
  String? _id;
  String? _status;
  String? _updateAt;
  String? _hasOrder;
  double? _normalSpeed;
  double? _firstRepeatSpeed;
  double? _secondRepeatSpeed;
  int? _part1Time;
  int? _part2Time;
  int? _part3Time;
  int? _takeNoteTime;

  TestDetailModel(
      {String? activityType,
      int? testOption,
      TopicModel? introduce,
      List<TopicModel>? part1,
      String? domainName,
      int? testId,
      String? checkSum,
      String? id,
      String? status,
      String? updateAt,
      String? hasOrder,
      TopicModel? part2,
      TopicModel? part3,
      double? normalSpeed,
      double? firstRepeatSpeed,
      double? secondRepeatSpeed}) {
    _activityType = activityType;
    _testOption = testOption;
    _introduce = introduce;
    _part1 = part1;
    _domainName = domainName;
    _testId = testId;
    _checkSum = checkSum;
    _id = id;
    _status = status;
    _updateAt = updateAt;
    _hasOrder = hasOrder;
    _part2 = part2;
    _part3 = part3;
    _normalSpeed = normalSpeed;
    _firstRepeatSpeed = firstRepeatSpeed;
    _secondRepeatSpeed = secondRepeatSpeed;
  }

  String get activityType => _activityType ?? "";
  set activityType(String activityType) => _activityType = activityType;
  int get testOption => _testOption ?? 0;
  set testOption(int testOption) => _testOption = testOption;
  TopicModel get introduce => _introduce ?? TopicModel(id: 0);
  set introduce(TopicModel introduce) => _introduce = introduce;
  List<TopicModel> get part1 => _part1 ?? [];
  set part1(List<TopicModel> part1) => _part1 = part1;
  String get domainName => _domainName ?? "";
  set domainName(String domainName) => _domainName = domainName;
  int get testId => _testId ?? 0;
  set testId(int testId) => _testId = testId;
  String get checkSum => _checkSum ?? "";
  set checkSum(String checkSum) => _checkSum = checkSum;
  String get id => _id ?? "";
  set id(String id) => _id = id;
  String get status => _status ?? "";
  set status(String status) => _status = status;
  String get updateAt => _updateAt ?? "";
  set updateAt(String updateAt) => _updateAt = updateAt;
  String get hasOrder => _hasOrder ?? "";
  set hasOrder(String hasOrder) => _hasOrder = hasOrder;
  TopicModel get part2 => _part2 ?? TopicModel();
  set part2(TopicModel part2) => _part2 = part2;
  TopicModel get part3 => _part3 ?? TopicModel();
  set part3(TopicModel part3) => _part3 = part3;
  dynamic get normalSpeed => _normalSpeed ?? 1.0;
  set normalSpeed(dynamic value) => _normalSpeed = value;
  get firstRepeatSpeed => _firstRepeatSpeed ?? 0.9;
  set firstRepeatSpeed(value) => _firstRepeatSpeed = value;
  get secondRepeatSpeed => _secondRepeatSpeed ?? 0.85;
  set secondRepeatSpeed(value) => _secondRepeatSpeed = value;
  int get part1Time => _part1Time ?? 30;

  set part1Time(int value) => _part1Time = value;

  int get part2Time => _part2Time ?? 120;

  set part2Time(value) => _part2Time = value;

  int get part3Time => _part3Time ?? 45;

  set part3Time(value) => _part3Time = value;

  int get takeNoteTime => _takeNoteTime ?? 60;

  set takeNoteTime(value) => _takeNoteTime = value;

  TestDetailModel.fromJson(Map<String, dynamic> json) {
    _activityType = json['activity_type'];
    _testOption = json['test_option'];
    _introduce = json['introduce'] != null
        ? TopicModel.fromJson(json['introduce'])
        : null;
    if (json['part1'] != null) {
      _part1 = <TopicModel>[];
      json['part1'].forEach((v) {
        _part1!.add(TopicModel.fromJson(v));
      });
    }
    _domainName = json['domain_name'];
    _testId = json['test_id'];
    _checkSum = json['check_sum'];
    _id = json['_id'];
    _status = json['status'];
    _updateAt = json['updated_at'];
    _hasOrder = json['has_order'];
    _part2 = json['part2'] != null ? TopicModel.fromJson(json['part2']) : null;
    _part3 = json['part3'] != null ? TopicModel.fromJson(json['part3']) : null;
    if (json['normal_speed'] != null) {
      _normalSpeed = Utils.instance().parseToDouble(json['normal_speed']);
    }
    if (json['first_repeat_speed'] != null) {
      _firstRepeatSpeed =
          Utils.instance().parseToDouble(json['first_repeat_speed']);
    }
    if (json['second_repeat_speed'] != null) {
      _secondRepeatSpeed =
          Utils.instance().parseToDouble(json['second_repeat_speed']);
    }

    _part1Time = json['part1_time'] ?? 30;
    _part2Time = json['part2_time'] ?? 120;
    _part3Time = json['part3_time'] ?? 45;
    _takeNoteTime = json['take_note_time'] ?? 60;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activity_type'] = _activityType;
    data['test_option'] = _testOption;
    if (_introduce != null) {
      data['introduce'] = _introduce!.toJson();
    }
    if (_part1 != null) {
      data['part1'] = _part1!.map((v) => v.toJson()).toList();
    }
    data['domain_name'] = _domainName;
    data['test_id'] = _testId;
    data['check_sum'] = _checkSum;
    data['_id'] = _id;
    data['status'] = _status;
    data['updated_at'] = _updateAt;
    data['has_order'] = _hasOrder;
    if (_part2 != null) {
      data['part2'] = _part2!.toJson();
    }
    if (_part3 != null) {
      data['part3'] = _part3!.toJson();
    }
    return data;
  }

  TestDetailModel.fromMyTestJson(Map<String, dynamic> json) {
    _id = json['_id'] ?? '';
    _status = json['status'].toString();
    _checkSum = json['check_sum'] ?? '';
    _testId = json['test_id'] ?? 0;
    _updateAt = json['updated_at'] ?? '';
    _hasOrder = json['has_order'].toString();

    _activityType = json['test']['activity_type'] ?? '';
    _testOption = json['test']['test_option'] ?? 0;
    _domainName = json['test']['domain_name'] ?? '';

    _introduce = json['test']['introduce'] != null
        ? TopicModel.fromJson(json['test']['introduce'])
        : null;
    if (json['test']['part1'] != null) {
      _part1 = <TopicModel>[];
      json['test']['part1'].forEach((v) {
        _part1!.add(TopicModel.fromJson(v));
      });
    }
    _part2 = json['test']['part2'] != null
        ? TopicModel.fromJson(json['test']['part2'])
        : null;
    _part3 = json['test']['part3'] != null
        ? TopicModel.fromJson(json['test']['part3'])
        : null;
  }
}
