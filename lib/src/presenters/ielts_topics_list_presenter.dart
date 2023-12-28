import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../data_source/constants.dart';
import '../data_source/dependency_injection.dart';
import '../data_source/repositories/practice_repository.dart';
import '../models/practice_model/ielts_topic_model.dart';
import '../models/practice_model/ielts_topics_list_result_model.dart';

abstract class IELTSTopicsListConstract {
  void getIELTSTopicsSuccess(
      List<IELTSTopicModel> topicsList, int? topicOption);
  void getIELTSTopicsFail(String message);
}

class IELTSTopicsListPresenter {
  final IELTSTopicsListConstract? _view;
  PracticeRepository? _repository;

  IELTSTopicsListPresenter(this._view) {
    _repository = Injector().getPracticeRepository();
  }

  Future getIELTSTopicsList(List<String> topicTypes, String status,
      {int? topicOption}) async {
    assert(_view != null && _repository != null);

    _repository!.getPracticeTopicsList(topicTypes, status).then((value) {
      if (kDebugMode) {
        print("DEBUG:getIELTSTopicsList: $value ");
      }
      Map<String, dynamic> dataMap = jsonDecode(value);

      if (dataMap[StringConstants.k_error_code] == 200) {
        IELTSListResultModel resultModel =
            IELTSListResultModel.fromJson(dataMap);
        _view!.getIELTSTopicsSuccess(resultModel.topics, topicOption);
      } else {
        _view!.getIELTSTopicsFail(Utils.instance()
            .multiLanguage(StringConstants.common_error_message));
      }
    }).catchError((error) {
      _view!.getIELTSTopicsFail(
          Utils.instance().multiLanguage(StringConstants.common_error_message));
    });
  }
}
