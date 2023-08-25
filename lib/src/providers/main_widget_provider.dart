import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';

import '../views/screens/auth/login_screen.dart';

class MainWidgetProvider extends ChangeNotifier {
  Widget _currentScreen = const HomeWorksWidget();
  Widget get currentScreen => _currentScreen;
  void setCurrentScreen(Widget current) {
    _currentScreen = current;
    notifyListeners();
  }
}
