import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key, required this.backButtonTapped});

  final Function backButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 10,
      child: InkWell(
        onTap: () {
          backButtonTapped();
        },
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: const Icon(
            Icons.arrow_back_outlined,
            color: AppColors.defaultPurpleColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}
