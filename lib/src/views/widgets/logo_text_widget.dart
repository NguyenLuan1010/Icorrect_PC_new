import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class LogoTextWidget extends StatelessWidget {
  const LogoTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'REACH YOUR DREAM TARGET',
        style: TextStyle(
          color: AppColors.defaultPurpleColor,
          fontSize: 13,
        ),
      ),
    );
  }
}
