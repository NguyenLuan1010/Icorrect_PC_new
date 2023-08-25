import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class InputFieldCustom {
  InputFieldCustom._();
  static final InputFieldCustom _inputFieldCustom = InputFieldCustom._();
  factory InputFieldCustom.init() => _inputFieldCustom;

  InputDecoration borderPurple10(String hint) {
    return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.gray,
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        // prefixIcon: Padding(
        //     padding: const EdgeInsets.only(left: 18, right: 12),
        //     child: Icon(iconData, color: AppThemes.colors.purple)),
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.purple),
            borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.purple),
            borderRadius: BorderRadius.circular(10)));
  }

  InputDecoration borderGray10(String hint) {
    return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.gray,
          fontWeight: FontWeight.w300,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        // prefixIcon: Padding(
        //     padding: const EdgeInsets.only(left: 18, right: 12),
        //     child: Icon(iconData, color: AppThemes.colors.purple)),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 1,
          ),
        ));
  }
}
