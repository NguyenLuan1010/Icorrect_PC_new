import 'package:flutter/material.dart';

import '../views/test/my_test/my_test_detail_tab.dart';

class MyTestProvider extends ChangeNotifier {
  Widget _curTab = MyTestTab();

  Widget get curTab => _curTab;

  set curTab(Widget tab) {
    _curTab = tab;
    notifyListeners();
  }
}