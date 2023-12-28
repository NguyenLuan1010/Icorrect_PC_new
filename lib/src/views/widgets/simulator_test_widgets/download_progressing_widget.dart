import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../models/ui_models/download_info.dart';
import '../../../providers/simulator_test_provider.dart';

class DownloadProgressingWidget extends StatelessWidget {
  DownloadProgressingWidget(this.downloadInfo, {super.key});

  DownloadInfo downloadInfo;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(AppAssets.img_download, width: 120, height: 120),
        const SizedBox(height: 8),
        //percent

        Text("${downloadInfo.strPercent}%",
            style: const TextStyle(
                color: AppColors.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),
        //progress bar
        SizedBox(
          width: w,
          child: _buildProgressBar(),
        ),
        const SizedBox(height: 8),
        //part of total
        Text("${downloadInfo.downloadIndex}/${downloadInfo.total}",
            style: const TextStyle(
                color: AppColors.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),
        Text(
            '${Utils.instance().multiLanguage(StringConstants.downloading)}...',
            style: const TextStyle(
                color: AppColors.defaultLightPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      backgroundColor: AppColors.defaultLightGrayColor,
      minHeight: 10,
      borderRadius: BorderRadius.circular(10),
      valueColor:
          const AlwaysStoppedAnimation<Color>(AppColors.defaultPurpleColor),
      value: downloadInfo.downloadPercent,
    );
  }
}
