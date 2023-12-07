import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth/change_password_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../utils/Navigations.dart';
import '../../utils/utils.dart';
import '../dialogs/confirm_dialog.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/practice_screen.dart';
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
          "Homeworks",
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
          "Practice",
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
          provider.setCurrentScreen(const PracticeScreen());
        },
      ),
      ListTile(
        title: Text(
          "My Test",
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
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text(
          "Change Password",
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
          "Multi Language",
          style: CustomTextStyle.textWithCustomInfo(
            context: context,
            color: AppColors.defaultGrayColor,
            fontsSize: FontsSize.fontSize_15,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: const Icon(
          Icons.language,
          color: AppColors.defaultGrayColor,
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        title: Text(
          "Logout",
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
                    title: "Notification",
                    message: "Are you sure to logout ?",
                    cancelButtonTitle: "Cancel",
                    okButtonTitle: "Logout",
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
