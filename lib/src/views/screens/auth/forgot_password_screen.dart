import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../utils/define_object.dart';
import '../../widgets/input_field_custom.dart';
import 'login_screen.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _txtEmailController = TextEditingController();
  late AuthWidgetProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<AuthWidgetProvider>(context, listen: false);
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
        return _buildForgotPasswordFormMobile();
      } else {
        return _buildForgotPasswordFormDesktop();
      }
    }));
  }

  Widget _buildForgotPasswordFormMobile() {
    return Center(
      child: Container(
        width: 700,
        height: 300,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Please input your email to recover password !',
              style: TextStyle(
                  color: AppColors.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            _buildEmailField(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Send Verify Code")),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                _provider.setCurrentScreen(const LoginWidget());
              },
              child: const Text(
                'Back',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.purple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordFormDesktop() {
    return Center(
      child: Container(
        width: 700,
        height: 300,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Please input your email to recover password !',
              style: TextStyle(
                  color: AppColors.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            _buildEmailField(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Send Verify Code")),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                _provider.setCurrentScreen(const LoginWidget());
              },
              child: const Text(
                'Back',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.purple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email',
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: _txtEmailController,
          decoration:
              InputFieldCustom.init().borderGray10('VD: hocvien@gmail.com'),
        )
      ],
    );
  }
}
