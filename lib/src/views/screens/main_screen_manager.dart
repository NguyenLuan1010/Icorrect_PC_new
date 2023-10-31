import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/user_auth_detail_provider.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/confirm_dialog.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';
import 'package:icorrect_pc/src/views/screens/home/practice_screen.dart';
import 'package:icorrect_pc/src/views/screens/video_authentication/user_auth_status_detail_widget.dart';

import 'package:provider/provider.dart';

import '../../data_source/api_urls.dart';
import '../../data_source/constants.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  var HOMEWORK_ACTION_TAB = 'HOMEWORK_ACTION_TAB';
  var PRACTICE_ACTION_TAB = 'PRACTICE_ACTION_TAB';
  var LOGOUT_ACTION_TAB = 'LOGOUT_ACTION_TAB';

  late MainWidgetProvider _provider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<MainWidgetProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppAssets.bg_main), fit: BoxFit.fill),
          ),
          child: _mainItem(),
        ),
      ),
    );
  }

  Widget _mainItem() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: [_mainHeader(), _body()],
        ));
  }

  Widget _mainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Image(
                  width: 170, image: AssetImage(AppAssets.img_logo_app)),
              Consumer<MainWidgetProvider>(builder: (context, appState, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     _provider.setCurrentScreen(ChangeNotifierProvider(
                    //         create: (_) => UserAuthDetailProvider(),
                    //         child: const UserAuthDetailStatus()));
                    //   },
                    //   child: const Text('User Authentication',
                    //       style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.w500)),
                    // ),
                    const SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        _provider.setCurrentScreen(const HomeWorksWidget());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: AppColors.defaultPurpleColor, width: 1)),
                        child: const Text('Homeworks',
                            style: TextStyle(
                                color: AppColors.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 30),
                    // InkWell(
                    //   onTap: () {
                    //     _provider.setCurrentScreen(const PracticeScreen());
                    //   },
                    //   child: const Text('Practices',
                    //       style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.w500)),
                    // ),
                    //const SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        _showConfirmLogOut();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: AppColors.defaultPurpleColor, width: 1)),
                        child: const Text('Logout',
                            style: TextStyle(
                                color: AppColors.defaultPurpleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 30),
                    FutureBuilder(
                        future: Utils.instance().getCurrentUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<UserDataModel?> snapshot) {
                          return (snapshot.data != null)
                              ? Column(
                                  children: [
                                    _getCircleAvatar(snapshot.data),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                          snapshot
                                              .data!.profileModel.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)),
                                    )
                                  ],
                                )
                              : const SizedBox();
                        }),
                  ],
                );
              })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  static Widget _getCircleAvatar(UserDataModel? user) {
    return SizedBox(
      width: CustomSize.size_50,
      height: CustomSize.size_50,
      child: CircleAvatar(
        child:
            Consumer<HomeProvider>(builder: (context, homeWorkProvider, child) {
          return (homeWorkProvider.currentUser.userInfoModel.id != 0)
              ? CachedNetworkImage(
                  imageUrl:
                      fileEP(homeWorkProvider.currentUser.profileModel.avatar),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CustomSize.size_100),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.colorBurn,
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Image.asset(
                      AppAssets.default_avatar,
                      width: CustomSize.size_40,
                      height: CustomSize.size_40,
                    ),
                  ),
                )
              : CircleAvatar(
                  child: Image.asset(
                    AppAssets.default_avatar,
                    width: CustomSize.size_40,
                    height: CustomSize.size_40,
                  ),
                );
        }),
      ),
    );
  }

  void _showConfirmLogOut() {
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
                Utils.instance().clearCurrentUser();
                Utils.instance().setAccessToken('');
                Navigations.instance().goToAuthWidget(context);
              });
        });
  }

  Widget _body() {
    return Consumer<MainWidgetProvider>(
        builder: (context, appState, child) =>
            Expanded(child: appState.currentScreen));
  }
}
