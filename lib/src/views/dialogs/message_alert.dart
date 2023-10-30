import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class MessageDialog extends Dialog {
  BuildContext context;
  String message;

  MessageDialog({required this.context, required this.message, super.key});

  @override
  double? get elevation => 0;

  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.width;
    return Container(
      width: w / 3,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Notify",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    textAlign: TextAlign.center,
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  )),
              const Divider(
                color: AppColors.gray,
                height: 1,
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
