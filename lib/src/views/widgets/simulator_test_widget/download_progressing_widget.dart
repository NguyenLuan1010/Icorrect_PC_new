import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../../core/app_colors.dart';
import '../../../providers/simulator_test_provider.dart';

class DownloadProgressingWidget extends StatelessWidget {
  const DownloadProgressingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.img_download, width: 120, height: 120),
          const SizedBox(height: 8),
          //percent
          Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
            double p = provider.downloadingPercent * 100;
            return Text("${p.toStringAsFixed(0)}%",
                style: const TextStyle(
                    color: AppColors.defaultLightPurpleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold));
          }),
          const SizedBox(height: 8),
          //progress bar
          SizedBox(
            width: w,
            child: _buildProgressBar(),
          ),
          const SizedBox(height: 8),
          //part of total
          Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
            return Text("${provider.downloadingIndex}/${provider.total}",
                style: const TextStyle(
                    color: AppColors.defaultLightPurpleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold));
          }),
          const SizedBox(height: 8),
          const Text('Downloading...',
              style: TextStyle(
                  color: AppColors.defaultLightPurpleColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      return LinearProgressIndicator(
        backgroundColor: AppColors.defaultLightGrayColor,
        minHeight: 10,
        borderRadius: BorderRadius.circular(10),
        valueColor:
            const AlwaysStoppedAnimation<Color>(AppColors.defaultPurpleColor),
        value: provider.downloadingPercent,
      );
    });
  }
}
