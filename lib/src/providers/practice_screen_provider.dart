import 'package:flutter/foundation.dart';
import 'package:icorrect_pc/src/models/practice_model/ielts_topic_model.dart';

class PracticeScreenProvider extends ChangeNotifier {
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

  int _currentOption = 1;
  int get currentOption => _currentOption;
  void setCurrentTestOption(int option) {
    _currentOption = option;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicPart1 = {};
  Set<IELTSTopicModel> get topicPart1 => _topicPart1;
  void setTopicPart1(Set<IELTSTopicModel> topics) {
    _topicPart1.clear();
    _topicPart1.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicPart2 = {};
  Set<IELTSTopicModel> get topicPart2 => _topicPart2;
  void setTopicPart2(Set<IELTSTopicModel> topics) {
    _topicPart2.clear();
    _topicPart2.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicPart3 = {};
  Set<IELTSTopicModel> get topicPart3 => _topicPart3;
  void setTopicPart3(Set<IELTSTopicModel> topics) {
    _topicPart3.clear();
    _topicPart3.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicPart23 = {};
  Set<IELTSTopicModel> get topicPart23 => _topicPart23;
  void setTopicPart23(Set<IELTSTopicModel> topics) {
    _topicPart23.clear();
    _topicPart23.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicFull1 = {};
  Set<IELTSTopicModel> _topicFull23 = {};
  Set<IELTSTopicModel> get topicFull1 => _topicFull1;
  Set<IELTSTopicModel> get topicFull23 => _topicFull23;

  void setTopicPartFull1(Set<IELTSTopicModel> topicFull1) {
    _topicFull1.clear();
    _topicFull1.addAll(topicFull1);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void setTopicPartFull23(Set<IELTSTopicModel> topicFull23) {
    _topicFull23.clear();
    _topicFull23.addAll(topicFull23);
    if (!isDisposed) {
      notifyListeners();
    }
  }

/////////////////////////PART 1///////////////////////////////////////////////
  Set<IELTSTopicModel> _topicsPart1Selected = {};
  Set<IELTSTopicModel> get topicsPart1Selected => _topicsPart1Selected;
  void setTopicsPart1Selected(Set<IELTSTopicModel> topics) {
    _topicsPart1Selected.clear();
    _topicsPart1Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPart1(IELTSTopicModel topic) {
    _topicsPart1Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPart1(IELTSTopicModel topic) {
    _topicsPart1Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPart1() {
    _topicsPart1Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

///////////////////////////PART 2///////////////////////////////////////////////
  Set<IELTSTopicModel> _topicsPart2Selected = {};
  Set<IELTSTopicModel> get topicsPart2Selected => _topicsPart2Selected;
  void setTopicsPart2Selected(Set<IELTSTopicModel> topics) {
    _topicsPart2Selected.clear();
    _topicsPart2Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPart2(IELTSTopicModel topic) {
    _topicsPart2Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPart2(IELTSTopicModel topic) {
    _topicsPart2Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPart2() {
    _topicsPart2Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  /////////////////////////////PART 3//////////////////////////////////////////

  Set<IELTSTopicModel> _topicsPart3Selected = {};
  Set<IELTSTopicModel> get topicsPart3Selected => _topicsPart3Selected;
  void setTopicsPart3Selected(Set<IELTSTopicModel> topics) {
    _topicsPart3Selected.clear();
    _topicsPart3Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPart3(IELTSTopicModel topic) {
    _topicsPart3Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPart3(IELTSTopicModel topic) {
    _topicsPart3Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPart3() {
    _topicsPart3Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }
/////////////////////////////PART 2&3//////////////////////////////////////////

  Set<IELTSTopicModel> _topicsPart23Selected = {};
  Set<IELTSTopicModel> get topicsPart23Selected => _topicsPart23Selected;
  void setTopicsPart23Selected(Set<IELTSTopicModel> topics) {
    _topicsPart23Selected.clear();
    _topicsPart23Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPart23(IELTSTopicModel topic) {
    _topicsPart23Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPart23(IELTSTopicModel topic) {
    _topicsPart23Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPart23() {
    _topicsPart23Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  /////////////////////////////FULL PART////////////////////////////////////////
  Set<IELTSTopicModel> _topicsPartFull1Selected = {};
  Set<IELTSTopicModel> get topicsPartFull1Selected => _topicsPartFull1Selected;
  void setTopicsPartFull1Selected(Set<IELTSTopicModel> topics) {
    _topicsPartFull1Selected.clear();
    _topicsPartFull1Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPartFull1(IELTSTopicModel topic) {
    _topicsPartFull1Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPartFull1(IELTSTopicModel topic) {
    _topicsPartFull1Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPartFull1() {
    _topicsPartFull1Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Set<IELTSTopicModel> _topicsPartFull23Selected = {};
  Set<IELTSTopicModel> get topicsPartFull23Selected =>
      _topicsPartFull23Selected;
  void setTopicsPartFull23Selected(Set<IELTSTopicModel> topics) {
    _topicsPartFull23Selected.clear();
    _topicsPartFull23Selected.addAll(topics);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addTopicsPartFull23(IELTSTopicModel topic) {
    _topicsPartFull23Selected.add(topic);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTopicPartFull23(IELTSTopicModel topic) {
    _topicsPartFull23Selected.removeWhere((element) => element.id == topic.id);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearTopicsSelectedPartFull23() {
    _topicsPartFull23Selected.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
