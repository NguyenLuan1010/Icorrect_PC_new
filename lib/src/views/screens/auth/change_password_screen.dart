import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../presenters/change_password_presenter.dart';
import '../../dialogs/message_alert.dart';
import '../home/home_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    implements ChangePasswordViewContract {
  bool _passVisibility = true;
  final _txtOldPasswordController = TextEditingController();
  final _txtNewPasswordController = TextEditingController();
  final _txtConfirmPasswordController = TextEditingController();
  CircleLoading? _loading;
  MainWidgetProvider? _mainWidgetProvider;
  ChangePasswordPresenter? _changePasswordPresenter;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _changePasswordPresenter = ChangePasswordPresenter(this);
    _mainWidgetProvider =
        Provider.of<MainWidgetProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 2;
    double h = MediaQuery.of(context).size.height / 1.5;
    return Center(
      child: Container(
        width: w,
        height: h,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                Utils.instance().multiLanguage(
                    StringConstants.change_password_menu_item_title),
                style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.defaultPurpleColor,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPasswordField(
                Utils.instance()
                    .multiLanguage(StringConstants.old_password_title),
                _txtOldPasswordController),
            const SizedBox(height: 15),
            _buildPasswordField(
                Utils.instance().multiLanguage(StringConstants.new_password),
                _txtNewPasswordController),
            const SizedBox(height: 15),
            _buildPasswordField(
                Utils.instance()
                    .multiLanguage(StringConstants.confirm_new_password),
                _txtConfirmPasswordController),
            const SizedBox(height: 40),
            SizedBox(
              width: w / 3,
              child: ElevatedButton(
                onPressed: () {
                  _onClickSaveChange();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColors.purple),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)))),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        Utils.instance().multiLanguage(
                            StringConstants.save_change_button_title),
                        style: const TextStyle(
                            fontSize: 17, color: Colors.white))),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: w / 3,
              child: ElevatedButton(
                onPressed: () {
                  _mainWidgetProvider!
                      .setCurrentScreen(const HomeWorksWidget());
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.defaultLightGrayColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)))),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        Utils.instance()
                            .multiLanguage(StringConstants.cancel_button_title),
                        style: const TextStyle(
                            fontSize: 17,
                            color: AppColors.defaultPurpleColor,
                            fontWeight: FontWeight.w600))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          key: const Key('password-input'),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _passVisibility,
          controller: controller,
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

  void _onClickSaveChange() {
    _loading?.show(context);
    String messageVerification = _getMessageVerification();
    if (messageVerification.isNotEmpty) {
      _loading!.hide();
      showDialog(
          context: context,
          builder: (context) {
            return MessageDialog(
                context: context, message: messageVerification);
          });
      return;
    }

    String oldPassword = _txtOldPasswordController.text.trim();
    String newPassword = _txtNewPasswordController.text.trim();
    String confirmPassword = _txtConfirmPasswordController.text.trim();

    _changePasswordPresenter!
        .changePassword(context, oldPassword, newPassword, confirmPassword);
  }

  String _getMessageVerification() {
    String oldPassword = _txtOldPasswordController.text.trim();
    String newPassword = _txtNewPasswordController.text.trim();
    String confirmPassword = _txtConfirmPasswordController.text.trim();
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return Utils.instance()
          .multiLanguage(StringConstants.please_complete_all_info);
    }
    if (oldPassword == newPassword) {
      return Utils.instance().multiLanguage(
          StringConstants.old_password_equals_new_password_error_message);
    }
    if (newPassword != confirmPassword) {
      return Utils.instance()
          .multiLanguage(StringConstants.confirm_password_warning);
    }
    return "";
  }

  @override
  void onChangePasswordComplete() {
    _loading!.hide();
    _txtOldPasswordController.clear();
    _txtNewPasswordController.clear();
    _txtConfirmPasswordController.clear();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context,
              message: Utils.instance()
                  .multiLanguage(StringConstants.change_password_success));
        });
  }

  @override
  void onChangePasswordError(String message) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }
}
