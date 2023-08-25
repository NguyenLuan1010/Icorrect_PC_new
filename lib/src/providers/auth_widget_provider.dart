import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/views/screens/auth/login_screen.dart';

class AuthWidgetProvider extends ChangeNotifier {
  Widget _currentScreen = const LoginWidget();
  Widget get currentScreen => _currentScreen;
  void setCurrentScreen(Widget current) {
    _currentScreen = current;
    notifyListeners();
  }
}
