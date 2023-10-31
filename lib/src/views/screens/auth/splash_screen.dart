import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/main.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_info_model.dart';
import 'package:icorrect_pc/src/presenters/auth_presenter.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/screens/auth_screen_manager.dart';
import 'package:icorrect_pc/src/views/screens/main_screen_manager.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/local/app_shared_preferences_keys.dart';
import '../../../data_source/local/app_shared_references.dart';
import '../../../utils/navigations.dart';
import '../../dialogs/message_alert.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> implements AuthConstract {
  AuthPresenter? _authPresenter;

  @override
  void initState() {
    _authPresenter = AuthPresenter(this);
    _getAppConfigInfo();
    super.initState();
  }

  void _getAppConfigInfo() async {
    String appConfigInfo =
        await AppSharedPref.instance().getString(key: AppSharedKeys.secretkey);
    if (appConfigInfo.isEmpty) {
      _authPresenter!.getAppConfigInfo();
    } else {
      _autoLogin();
    }
  }

  void _autoLogin() async {
    String token = await Utils.instance().getAccessToken() ?? "";
    Timer(const Duration(milliseconds: 2000), () async {
      if (token.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainWidget(),
          ),
          ModalRoute.withName('/'),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthWidget(),
          ),
          ModalRoute.withName('/'),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildSplashScreen();
  }

  Widget _buildSplashScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              width: 300,
              image: AssetImage(AppAssets.img_logo_app),
              fit: BoxFit.fill,
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: AppColors.purpleSlight2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onGetAppConfigInfoFail(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onGetAppConfigInfoSuccess() {
    _autoLogin();
  }
}
