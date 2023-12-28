import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../utils/utils.dart';

class LanguageSelectionDialog extends StatefulWidget {
  const LanguageSelectionDialog({super.key});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  double w = 0, h = 0;
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Center(
      child: Wrap(
        children: [
          Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: w / 4,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.g_translate,
                      color: AppColors.defaultPurpleColor, size: 35),
                  const SizedBox(height: 10),
                  Text(
                    Utils.instance().multiLanguage(
                        StringConstants.select_your_language_title),
                    style: const TextStyle(
                      color: AppColors.defaultPurpleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _languageItem(false),
                  _languageItem(true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageItem(bool isEnglish) {
    return InkWell(
      splashColor: AppColors.defaultPurpleColor,
      onTap: () {
        localization.translate(isEnglish ? 'en' : 'vn');
        Provider.of<HomeProvider>(context, listen: false).setStatusActivity(
            Utils.instance().multiLanguage(StringConstants.all));
        Provider.of<HomeProvider>(context, listen: false).setStatusSelections([
          Utils.instance().multiLanguage(StringConstants.all),
          Utils.instance().multiLanguage(StringConstants.submitted),
          Utils.instance().multiLanguage(StringConstants.corrected),
          Utils.instance().multiLanguage(StringConstants.not_completed),
          Utils.instance().multiLanguage(StringConstants.late_title),
          Utils.instance().multiLanguage(StringConstants.out_of_date)
        ]);
        Provider.of<HomeProvider>(context, listen: false)
            .classesList
            .elementAt(0)
            .name = Utils.instance().multiLanguage(StringConstants.all);
        Navigator.of(context).pop();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image(
                  image: AssetImage(isEnglish
                      ? AppAssets.img_english
                      : AppAssets.img_vietnamese),
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 20),
                Text(
                  Utils.instance().multiLanguage(
                      isEnglish ? StringConstants.ens : StringConstants.vn),
                  style: const TextStyle(
                    color: AppColors.defaultPurpleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
            const Icon(
              Icons.navigate_next,
              size: 30,
              color: AppColors.defaultPurpleColor,
            )
          ],
        ),
      ),
    );
  }
}
