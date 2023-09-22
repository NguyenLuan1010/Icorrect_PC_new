import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/providers/play_answer_provider.dart';
import 'package:icorrect_pc/src/providers/re_answer_provider.dart';
import 'package:icorrect_pc/src/providers/simulator_test_provider.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/providers/timer_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth/login_screen.dart';
import 'package:icorrect_pc/src/views/screens/auth_screen_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'src/views/screens/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setMinimumSize(Size(1200, 800));
      await windowManager.center();
      await windowManager.show();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthWidgetProvider()),
          ChangeNotifierProvider(create: (_) => MainWidgetProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => SimulatorTestProvider()),
          ChangeNotifierProvider(create: (_) => ReAnswerProvider()),
          ChangeNotifierProvider(create: (_) => PlayAnswerProvider()),
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          ChangeNotifierProvider(create: (_) => TestRoomProvider()),
          ChangeNotifierProvider(create: (_) => MyTestProvider())
        ],
        child: const MaterialApp(
            debugShowCheckedModeBanner: false, home: SplashScreen()));
  }
}
