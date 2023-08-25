import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class ButtonCustom {
  ButtonCustom._();
  static final ButtonCustom _buttonCustom = ButtonCustom._();
  factory ButtonCustom.init() => _buttonCustom;

  ButtonStyle buttonPurple20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppColors.purple),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonBlue20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppColors.facebookColor),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonWhite20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppColors.white),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }
}
