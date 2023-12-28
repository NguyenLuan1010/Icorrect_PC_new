import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/screens/practice/each_part_screen.dart';
import 'package:icorrect_pc/src/views/screens/practice/full_part_screen.dart';
import 'package:provider/provider.dart';

import '../../../providers/practice_screen_provider.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  PracticeScreenProvider? _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<PracticeScreenProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Utils.instance().getDevicesWidth(context) * 0.055,
            vertical: Utils.instance().getDevicesHeight(context) * 0.03,
          ),
          child: Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.defaultGrayColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  width: Utils.instance().getDevicesWidth(context),
                  height: Utils.instance().getDevicesHeight(context),
                  child: const GridPaper(
                    color: AppColors.purpleSlight,
                    divisions: 1,
                    interval: 200,
                    subdivisions: 10,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        Utils.instance().getDevicesWidth(context) * 0.05,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height:
                            Utils.instance().getDevicesHeight(context) - 200,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            _buildTopicBackground(),
                            SizedBox(
                              height:
                                  Utils.instance().getDevicesHeight(context) *
                                      0.8,
                              child: ListView(
                                // physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildPartItem(
                                      title: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_1_title),
                                      content: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_1_description),
                                      testOption: IELTSTestOption.part1.get),
                                  _buildPartItem(
                                      title: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_2_title),
                                      content: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_2_description),
                                      testOption: IELTSTestOption.part2.get),
                                  _buildPartItem(
                                      title: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_3_title),
                                      content: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_3_description),
                                      testOption: IELTSTestOption.part3.get),
                                  _buildPartItem(
                                      title: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_2_3_title),
                                      content: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_part_2_3_description),
                                      testOption:
                                          IELTSTestOption.part2and3.get),
                                  _buildPartItem(
                                      title: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_full_test_title),
                                      content: Utils.instance().multiLanguage(
                                          StringConstants
                                              .practice_card_full_test_description),
                                      testOption: IELTSTestOption.full.get),
                                ],
                              ),
                            ),
                            appState.currentOption != IELTSTestOption.full.get
                                ? EachPartScreen(
                                    provider: appState,
                                    testOption: appState.currentOption)
                                : FullPartScreen(provider: _provider!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPartItem(
      {required String title,
      required String content,
      required int testOption}) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      return GestureDetector(
        onTap: () {
          appState.setCurrentTestOption(testOption);
        },
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              _buildPartItemBackground(title: title, testOption: testOption),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      height: 78,
                      width: appState.currentOption == testOption
                          ? Utils.instance().getDevicesWidth(context) * 0.46
                          : Utils.instance().getDevicesWidth(context) * 0.30,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.defaultWhiteColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          appState.currentOption == testOption
                              ? const BoxShadow()
                              : BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width:
                                  Utils.instance().getDevicesWidth(context) / 4,
                              child: Text(
                                content,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPartItemBackground(
      {required String title, required int testOption}) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
            child: Container(
              width: Utils.instance().getDevicesWidth(context) * 0.45,
              height: 85,
              color: appState.currentOption == testOption
                  ? AppColors.defaultPurpleColor
                  : Colors.transparent,
            ),
          )
        ],
      );
    });
  }

  Widget _buildTopicBackground() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: Utils.instance().getDevicesWidth(context) * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: AppColors.defaultPurpleColor,
          ),
        ),
      ],
    );
  }
}
