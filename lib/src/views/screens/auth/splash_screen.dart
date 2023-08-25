import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/main.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_info_model.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/local/app_shared_references.dart';
import '../../../utils/navigations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkUserCookies();
    super.initState();
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

  Future _checkUserCookies() async {
    int daysSaveCookie = 25;
    UserDataModel? user =
        await Utils.instance().getCurrentUser() ?? UserDataModel();
    String saveTime = await Utils.instance().getCookiesTime() ?? '';

    if (user != null && saveTime.isNotEmpty) {
      DateTime today = DateTime.now();
      DateTime savedTime = DateTime.parse(saveTime);
      Duration timeRange = today.difference(savedTime);
      if (timeRange.inDays >= daysSaveCookie) {
        Utils.instance().clearCurrentUser();
      }
    }

    String token = await Utils.instance().getAccessToken();

    Future.delayed(const Duration(seconds: 1), () {
      if (user == null || user.userInfoModel.email.isEmpty && token.isEmpty) {
        Navigations.instance().goToAuthWidget(context);
      } else {
        Navigations.instance().goToMainWidget(context);
      }
    });
  }
}
