import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/my_practice_tests_provider.dart';
import 'package:icorrect_pc/src/providers/practice_screen_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth/change_password_screen.dart';
import 'package:icorrect_pc/src/views/test/my_practice_tests/my_practice_tests.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../utils/Navigations.dart';
import '../../utils/utils.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/language_selection_dialog.dart';
import '../screens/home/home_screen.dart';
import '../screens/practice/practice_screen.dart';
import '../screens/video_authentication/user_auth_status_detail_widget.dart';

Widget navbarItems(
    {required BuildContext context, required MainWidgetProvider provider}) {
  return ListView(
    // padding: EdgeInsets.zero,
    children: [
      Consumer<HomeProvider>(
        builder: (context, homeWorkProvider, child) {
          return Utils.instance()
              .drawHeader(context, homeWorkProvider.currentUser);
        },
      ),
      ListTile(
        title: Text(
          Utils.instance().multiLanguage(StringConstants.home_menu_item_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.home_outlined,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          Navigator.pop(context);
          provider.setCurrentScreen(const HomeWorksWidget());
        },
      ),
      ListTile(
        title: Text(
          Utils.instance().multiLanguage(StringConstants.practice_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.menu_book,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          Navigator.pop(context);
          provider.setCurrentScreen(ChangeNotifierProvider(
              create: (_) => PracticeScreenProvider(),
              child: const PracticeScreen()));
        },
      ),
      ListTile(
        title: Text(
          Utils.instance().multiLanguage(StringConstants.my_test_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.list_alt,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          provider.setCurrentScreen(ChangeNotifierProvider(
              create: (_) => MyPracticeTestsProvider(),
              child: const MyPracticeTests()));
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text(
          Utils.instance()
              .multiLanguage(StringConstants.change_password_menu_item_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.password_outlined,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          Navigator.pop(context);
          provider.setCurrentScreen(const ChangePasswordScreen());
        },
      ),
      // ListTile(
      //   title: Text(
      //     "Video Authentication",
      //     style: CustomTextStyle.textWithCustomInfo(
      //       context: context,
      //       color: AppColors.defaultGrayColor,
      //       fontsSize: FontsSize.fontSize_15,
      //       fontWeight: FontWeight.w400,
      //     ),
      //   ),
      //   leading: const Icon(
      //     Icons.video_camera_front_outlined,
      //     color: AppColors.defaultGrayColor,
      //   ),
      //   onTap: () {
      //     Navigator.pop(context);
      //     provider.setCurrentScreen(const UserAuthDetailStatus());
      //   },
      // ),
      ListTile(
        title: Text(
          Utils.instance().multiLanguage(StringConstants.multi_language_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.defaultPurpleColor),
              borderRadius: BorderRadius.circular(100)),
          child: Image(
            image: AssetImage(Utils.instance().getLanguageImg()),
            width: 25,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (builder) {
              return const LanguageSelectionDialog();
            },
          ).then((value) => Navigator.pop(context));
        },
      ),
      ListTile(
        title: Text(
          Utils.instance()
              .multiLanguage(StringConstants.logout_menu_item_title),
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.logout_outlined,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (_) {
                return ConfirmDialogWidget(
                    title: Utils.instance()
                        .multiLanguage(StringConstants.dialog_title),
                    message: Utils.instance()
                        .multiLanguage(StringConstants.logout_confirm_message),
                    cancelButtonTitle: Utils.instance()
                        .multiLanguage(StringConstants.cancel_button_title),
                    okButtonTitle: Utils.instance()
                        .multiLanguage(StringConstants.logout_menu_item_title),
                    cancelButtonTapped: () {},
                    okButtonTapped: () {
                      Utils.instance().sendLog();
                      Utils.instance().clearCurrentUser();
                      Utils.instance().setAccessToken('');
                      Navigations.instance().goToAuthWidget(context);
                    });
              });
        },
      ),
    ],
  );
}
