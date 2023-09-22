import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';

import '../../../core/app_colors.dart';
import '../../presenters/my_test_presenter.dart';
import '../../presenters/simulator_test_presenter.dart';

class DownloadAgainWidget extends StatelessWidget {
  const DownloadAgainWidget(
      {super.key,
      required this.onClickTryAgain});

  final Function onClickTryAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Download icon
            Image.asset(
              AppAssets.img_connect_internet,
              width: 120,
              height: 120,
            ),
            //Message
            const Padding(
              padding:
                  EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
              child: Center(
                child: Text(
                  "A part of data has not downloaded properly. Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            //Try Again button
            InkWell(
              onTap: () {
                onClickTryAgain();
              },
              child: const SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.defaultPurpleColor,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
