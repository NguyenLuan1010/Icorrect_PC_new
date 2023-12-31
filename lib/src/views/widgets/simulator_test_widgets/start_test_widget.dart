import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../providers/test_room_provider.dart';

class StartTestWidget extends StatelessWidget {
  Function onClickStartTest;
  StartTestWidget({super.key, required this.onClickStartTest});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestRoomProvider>(builder: (context, provider, child) {
      return Visibility(
          visible: !provider.isStartTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.img_start,
                width: 150,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  provider.setStartTest(true);
                  onClickStartTest();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.purpleBlue),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)))),
                child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Start Test", style: TextStyle(fontSize: 17))),
              )
            ],
          ));
    });
  }
}
