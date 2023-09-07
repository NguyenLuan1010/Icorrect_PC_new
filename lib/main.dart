import 'dart:io';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth/login_screen.dart';
import 'package:icorrect_pc/src/views/screens/auth_screen_manager.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'src/views/screens/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    // WindowManager.instance.setMinimumSize(const Size(700, 800));
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1380, 920),
      minimumSize: Size(1380, 920),
      center: true,
      skipTaskbar: true,
      windowButtonVisibility: true,
      titleBarStyle: TitleBarStyle.normal,
      backgroundColor: Colors.transparent,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
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
        ],
        child: const MaterialApp(
            debugShowCheckedModeBanner: false, home: SplashScreen()));
  }
}
