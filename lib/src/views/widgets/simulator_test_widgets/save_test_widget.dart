import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/presenters/test_room_simulator_presenter.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../providers/simulator_test_provider.dart';
import '../button_custom.dart';

class SaveTheTestWidget extends StatelessWidget {
  final Function _onClickSaveTheTest;
  const SaveTheTestWidget(this._onClickSaveTheTest, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulatorTestProvider>(
      builder: (context, simulatorTestProvider, child) {
        return Visibility(
          visible: simulatorTestProvider.isVisibleSaveTheTest ||
              simulatorTestProvider.reanswersList.isNotEmpty,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                  image: AssetImage(_getImage(simulatorTestProvider)),
                  width: 150),
              Text(_getTitle(simulatorTestProvider),
                  style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      color: simulatorTestProvider.reanswersList.isNotEmpty
                          ? AppColors.defaultPurpleColor
                          : Colors.green)),
              const SizedBox(height: 10),
              Text(
                _getContent(simulatorTestProvider),
                style: const TextStyle(
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
                  child: Text(
                    _getTitleButton(simulatorTestProvider),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _getImage(SimulatorTestProvider provider) {
    return provider.reanswersList.isNotEmpty
        ? AppAssets.img_QA
        : AppAssets.img_completed;
  }

  String _getTitle(SimulatorTestProvider provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.instance().multiLanguage(StringConstants.reanswer_question)
        : Utils.instance().multiLanguage(StringConstants.congratulations);
  }

  String _getContent(SimulatorTestProvider provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.instance().multiLanguage(StringConstants.reanswer_description)
        : Utils.instance()
            .multiLanguage(StringConstants.finish_test_description);
  }

  String _getTitleButton(SimulatorTestProvider provider) {
    return provider.reanswersList.isNotEmpty
        ? Utils.instance().multiLanguage(StringConstants.update_your_answer)
        : Utils.instance().multiLanguage(StringConstants.save_the_test);
  }
}
