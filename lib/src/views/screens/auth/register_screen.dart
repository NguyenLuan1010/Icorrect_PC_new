import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:provider/provider.dart';

import '../../../utils/define_object.dart';
import '../../widgets/input_field_custom.dart';
import 'login_screen.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();
  final _txtConfirmPasswordController = TextEditingController();
  bool _passVisibility = true;
  bool _cofirmPassVisibility = true;
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
        return _buildRegisterFormMobile();
      } else {
        return _buildRegisterFormDesktop();
      }
    }));
  }

  Widget _buildRegisterFormMobile() {
    return Center(
      child: Container(
        width: 700,
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
            _buildConfirmPasswordField(),
            const SizedBox(height: 15),
            _buildLinkText(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Register")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterFormDesktop() {
    return Center(
      child: Container(
        width: 700,
        height: 450,
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
            _buildConfirmPasswordField(),
            const SizedBox(height: 15),
            _buildLinkText(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Register")),
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

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Password',
            style: TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          key: const Key('password-input'),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _cofirmPassVisibility,
          controller: _txtConfirmPasswordController,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
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
                icon: _cofirmPassVisibility
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _cofirmPassVisibility = !_cofirmPassVisibility;
                  });
                },
              )),
        )
      ],
    );
  }

  Widget _buildLinkText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'You had an account ?',
          style: TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            _provider.setCurrentScreen(const LoginWidget());
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
        )
      ],
    );
  }
}
