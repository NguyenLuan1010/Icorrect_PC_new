import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/presenters/test_room_simulator_presenter.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../presenters/test_room_presenter.dart';
import '../../../providers/simulator_test_provider.dart';
import '../button_custom.dart';

class SaveTheTestWidget extends StatelessWidget {
  final Function _onClickSaveTheTest;
  const SaveTheTestWidget(this._onClickSaveTheTest, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestRoomProvider>(
      builder: (context, simulatorTestProvider, child) {
        return Visibility(
          visible: simulatorTestProvider.isVisibleSaveTheTest,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                  image: AssetImage(AppAssets.img_completed), width: 150),
              const Text('Congratulations',
                  style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 10),
              const Text(
                "You have completed the speaking test ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.defaultGrayColor),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    _onClickSaveTheTest();
                  },
                  style: ButtonCustom.init().buttonPurple20(),
                  child: const Text(
                    "Save the test",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
