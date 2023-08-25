import 'package:flutter/material.dart';

class TextFieldCustom {
  TextFieldCustom._();
  static final TextFieldCustom _textFieldCustom = TextFieldCustom._();
  factory TextFieldCustom.init() => _textFieldCustom;

  TextStyle underline(dynamic colorStyle) {
    return  TextStyle(
        color: colorStyle,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline,
        decorationColor: colorStyle);
  }
}
