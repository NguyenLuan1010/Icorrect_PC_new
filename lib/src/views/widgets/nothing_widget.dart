import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';

import '../../../core/app_colors.dart';

class NothingWidget {
  NothingWidget._();
  static final NothingWidget _widget = NothingWidget._();
  factory NothingWidget.init() => _widget;

  Widget buildNothingWidget(String message,
      {required double? widthSize, required double? heightSize}) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: widthSize,
            height: heightSize,
            child: const Image(
              image: AssetImage(AppAssets.img_empty),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
                color: AppColors.gray,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
