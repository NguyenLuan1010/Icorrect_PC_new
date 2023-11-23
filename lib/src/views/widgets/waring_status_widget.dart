import 'package:flutter/material.dart';

import '../../data_source/constants.dart';

class WarningStatusWidget extends StatelessWidget {
  WarningStatusWidget(
      {required this.title,
      required this.content,
      required this.cancelButtonName,
      required this.okButtonName,
      required this.cancelAction,
      required this.okAction,
      required this.isWarningConfirm,
      super.key});
  String title;
  String content;
  String cancelButtonName;
  String okButtonName;
  Function cancelAction;
  bool isWarningConfirm;
  Function okAction;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    MaterialColor colorDefault = _getColor(isWarningConfirm);

    return Container(
      width: w / 2,
      margin: const EdgeInsets.only(top: 35, left: 20, right: 20),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorDefault, width: 5),
            right: BorderSide(color: colorDefault, width: 1),
            left: BorderSide(color: colorDefault, width: 1),
            bottom: BorderSide(color: colorDefault, width: 1),
          ),
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    _getIcon(isWarningConfirm),
                    color: colorDefault,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: CustomTextStyle.textBlackBold_14,
                      ),
                      SizedBox(
                        width: w / 4,
                        child:
                            Text(content, style: CustomTextStyle.textBlack_14),
                      )
                    ],
                  )
                ],
              )),
          if (isWarningConfirm)
            Expanded(
                  child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      cancelAction();
                    },
                    child: Text(cancelButtonName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey))),
                TextButton(
                    onPressed: () {
                      okAction();
                    },
                    child: Text(okButtonName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: colorDefault)))
              ],
            ))
        ],
      ),
    );
  }

  MaterialColor _getColor(bool isWarningConfirm) {
    return isWarningConfirm ? Colors.amber : Colors.blue;
  }

  IconData _getIcon(bool isWarningConfirm) {
    return isWarningConfirm ? Icons.warning_amber_rounded : Icons.info_outline;
  }
}
