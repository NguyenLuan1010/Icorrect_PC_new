import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/presenters/login_presenter.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/views/screens/auth/register_screen.dart';

import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/local/app_shared_preferences_keys.dart';
import '../../../data_source/local/app_shared_references.dart';
import '../../../utils/Navigations.dart';
import '../../../utils/define_object.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/input_field_custom.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginWidget> implements LoginViewContract {
  CircleLoading? _loading;
  late AuthWidgetProvider _provider;
  LoginPresenter? _loginPresenter;

  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();
  bool _passVisibility = true;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _loginPresenter = LoginPresenter(this);
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
    return _buildLoginForm();
  }

  Widget _buildLoginForm() {
    double w = MediaQuery.of(context).size.width / 2;
    double h = MediaQuery.of(context).size.height / 1.8;
    return Center(
      child: Container(
        width: w,
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 15),
            _buildPasswordField(),
            const SizedBox(height: 15),
            _buildLinkText(),
            const SizedBox(height: 40),
            SizedBox(
              width: w / 3,
              child: ElevatedButton(
                onPressed: () {
                  _loading?.show(context);
                  _onPressLogin();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.purple),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)))),
                child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("Sign In", style: TextStyle(fontSize: 17))),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password',
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          key: const Key('password-input'),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _passVisibility,
          controller: _txtPasswordController,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
              // prefixIcon: Padding(
              //     padding: const EdgeInsets.only(left: 18, right: 12),
              //     child: Icon(iconData, color: AppThemes.colors.purple)),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1,
                ),
              ),
              suffixIcon: IconButton(
                icon: _passVisibility
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _passVisibility = !_passVisibility;
                  });
                },
              )),
        )
      ],
    );
  }

  Widget _buildLinkText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'You don not have an account',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                _provider.setCurrentScreen(const RegisterWidget());
              },
              child: const Text(
                'Register',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            )
          ],
        ),
        InkWell(
          onTap: () {
            _provider.setCurrentScreen(const ForgotPasswordWidget());
          },
          child: const Text(
            'Forgot password ?',
            style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  void _onPressLogin() {
    String email = _txtEmailController.text.trim();
    String password = _txtPasswordController.text.trim();

    LoginPresenter presenter = LoginPresenter(this);
    presenter.login(email, password);
  }

  @override
  void onLoginComplete() {
    _loading?.hide();
    Navigations.instance().goToMainWidget(context);
  }

  @override
  void onLoginError(String message) {
    _loading?.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });
  }
}
