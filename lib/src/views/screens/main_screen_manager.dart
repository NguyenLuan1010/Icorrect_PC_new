import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';
import 'package:icorrect_pc/src/views/screens/home/practice_screen.dart';

import 'package:provider/provider.dart';

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
                    InkWell(
                      onTap: () {
                        _provider.setCurrentScreen(const HomeWorksWidget());
                      },
                      child: const Text('Homeworks',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        _provider.setCurrentScreen(const PracticeScreen());
                      },
                      child: const Text('Practices',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 30),
                    const Text('Logout',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),

                    // (appState.currentMainWidget.runtimeType ==
                    //             HomeWorksWidget ||
                    //         appState.currentMainWidget.runtimeType ==
                    //             PracticesWidget)
                    //     ? InkWell(
                    //         onTap: () {
                    //           showDialog(
                    //               context: context,
                    //               builder: (context) {
                    //                 return ConfirmDialog.init().showDialog(
                    //                     context,
                    //                     'Confirm to logout',
                    //                     'Are you sure for logout ?',
                    //                     this);
                    //               });
                    //         },
                    //         child: const Text('Logout',
                    //             style: TextStyle(
                    //                 color: Colors.black,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.w500)),
                    //       )
                    //     : Container(),
                    const SizedBox(width: 30),
                    FutureBuilder(
                        future: Utils.instance().getCurrentUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<UserDataModel?> snapshot) {
                          return _getCircleAvatar(snapshot.data);
                        })
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
    String strAvatar = (user != null && user != UserDataModel())
        ? user.profileModel.avatar ?? ''
        : '';
    if (strAvatar.contains("default-avatar") || strAvatar.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(AppAssets.default_avatar),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage('APIHelper.API_DOMAIN + strAvatar'),
    );
  }

  // static Widget _getCircleAvatar(UserDataModel? user) {
   
  //   return CircleAvatar(
  //             child: Consumer<HomeProvider>(
  //                 builder: (context, homeWorkProvider, child) {
  //               return CachedNetworkImage(
  //                 imageUrl:
  //                     fileEP(homeWorkProvider.currentUser.profileModel.avatar),
  //                 imageBuilder: (context, imageProvider) => Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(CustomSize.size_100),
  //                     image: DecorationImage(
  //                       image: imageProvider,
  //                       fit: BoxFit.cover,
  //                       colorFilter: const ColorFilter.mode(
  //                         Colors.transparent,
  //                         BlendMode.colorBurn,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 placeholder: (context, url) =>
  //                     const CircularProgressIndicator(),
  //                 errorWidget: (context, url, error) => CircleAvatar(
  //                   child: Image.asset(
  //                     AppAssets.default_avatar,
  //                     width: CustomSize.size_40,
  //                     height: CustomSize.size_40,
  //                   ),
  //                 ),
  //               );
  //             })
  //   );
  // }


  Widget _body() {
    return Consumer<MainWidgetProvider>(
        builder: (context, appState, child) =>
            Expanded(flex: 1, child: appState.currentScreen));
  }

  void whenOutTheTest(String keyInfo) {
    // AlertInfo info = AlertInfo(
    //     'Warning',
    //     'Are you sure to out this test? Your test won\'t be saved !',
    //     Alert.WARNING.type);
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertsDialog.init()
    //           .showDialog(context, info, this, keyInfo: keyInfo);
    //     });
  }

// @override
// void onClickCancel() {}

// @override
// void onClickOK() {
//   Navigations.instance().goToAuthWidget(context);
//   SharedRef.instance().setUser(null);
//   SharedRef.instance().setAccessToken('');
// }

// @override
// void onAlertExit(String keyInfo) {}

// @override
// void onAlertNextStep(String keyInfo) {
//   switch (keyInfo) {
//     case 'HOMEWORK_ACTION_TAB':
//       if (mounted) {
//         _provider.stopVideoController();
//         _provider.resetTestSimulatorValue();
//         _provider.setCurrentMainWidget(const HomeWorksWidget());
//       }
//       break;
//     case 'PRACTICE_ACTION_TAB':
//       _provider.stopVideoController();
//       _provider.resetTestSimulatorValue();
//       break;
//   }
// }
}