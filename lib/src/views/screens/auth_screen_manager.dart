import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';

import 'package:provider/provider.dart';


class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, constraints) {
          // if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
          //   return Container(
          //     padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //           image: AssetImage(AppAssets.bg_main), fit: BoxFit.fill),
          //     ),
          //     child: _mainItem(),
          //   );
          // } else {
          //   return Container(
          //     padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //           image: AssetImage(AppAssets.bg_login), fit: BoxFit.fill),
          //     ),
          //     child: _mainItem(),
          //   );
          // }
           return Container(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(AppAssets.bg_login), fit: BoxFit.fill),
              ),
              child: _mainItem(),
            );
        }),
      ),
    );
  }

  Widget _mainItem() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: [_mainHeader(), _buildAuthWidget()],
        ));
  }

  Widget _mainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image(width: 170, image: AssetImage(AppAssets.img_logo_app)),
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

  Widget _buildAuthWidget() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(0),
        color: const Color.fromARGB(0, 255, 255, 255),
        child: Consumer<AuthWidgetProvider>(builder: (context, appState, child) {
          return appState.currentScreen;
        }),
      ),
    );
  }
}
