import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
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
      return _buildForgotPasswordFormDesktop();
    }));
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
            Text(
              Utils.instance()
                  .multiLanguage(StringConstants.forgot_password_message),
              style: const TextStyle(
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
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(Utils.instance()
                      .multiLanguage(StringConstants.send_verify_code))),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                _provider.setCurrentScreen(const LoginWidget());
              },
              child: Text(
                Utils.instance()
                    .multiLanguage(StringConstants.back_button_title),
                style: const TextStyle(
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
        const Text(StringConstants.email,
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
