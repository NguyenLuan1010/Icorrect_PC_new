import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/camera_service.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/providers/record_video_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/api_urls.dart';
import '../../../data_source/constants.dart';
import '../../../models/ui_models/user_authen_status.dart';
import '../../../models/user_authentication/user_authentication_detail.dart';
import '../../../presenters/user_authentication_detail_presenter.dart';
import '../../../providers/camera_preview_provider.dart';
import '../../../providers/user_auth_detail_provider.dart';
import '../../../providers/video_play_provider.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/confirm_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../dialogs/record_video_authen_dialog.dart';
import '../../widgets/video_player_widget.dart';

class UserAuthDetailStatus extends StatefulWidget {
  const UserAuthDetailStatus({super.key});

  @override
  State<UserAuthDetailStatus> createState() => _UserAuthDetailStatusState();
}

class _UserAuthDetailStatusState extends State<UserAuthDetailStatus>
    implements UserAuthDetailContract {
  double w = 0, h = 0;

  UserAuthDetailProvider? _provider;
  UserAuthDetailPresenter? _authDetailPresenter;
  CircleLoading? _circleLoading;
  CameraPreviewProvider? _cameraPreviewProvider;
  @override
  void initState() {
    super.initState();

    _circleLoading = CircleLoading();
    _authDetailPresenter = UserAuthDetailPresenter(this);
    _provider = Provider.of<UserAuthDetailProvider>(context, listen: false);
    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);
    CameraService.instance().fetchCameras(provider: _cameraPreviewProvider!);
    _getUserAuthDetail();
  }

  void _getUserAuthDetail() {
    _circleLoading!.show(context);
    _authDetailPresenter!.getUserAuthDetail(context);
    Future.delayed(Duration.zero, () {
      _provider!.clearData();
    });
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Consumer<UserAuthDetailProvider>(
        builder: (context, provider, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (provider.startReload) {
          _getUserAuthDetail();
        }
      });
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
        decoration: BoxDecoration(
            color: const Color.fromARGB(32, 129, 118, 167),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.defaultPurpleColor, width: 2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: h / 3,
              width: w / 4,
              child: _userHadVideoAuth()
                  ? ChangeNotifierProvider(
                      create: (_) => VideoPlayProvider(),
                      child: VideoPlayerWidget(path: provider.filePathVideo))
                  : GestureDetector(
                      onTap: () {},
                      child: const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_camera_front_outlined,
                                size: 100,
                                color: AppColors.defaultPurpleSightColor),
                            Text(StringConstants.start_record_video_title,
                                style: TextStyle(
                                    color: AppColors.defaultGrayColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500))
                          ],
                        ),
                      )),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusVideo(),
                const SizedBox(height: 20),
                _submitVideoAgainButton()
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _statusVideo() {
    return Consumer<UserAuthDetailProvider>(
      builder: (context, provider, child) {
        UserAuthenStatusUI statusUI = Utils.instance()
            .getUserAuthenStatus(provider.userAuthenDetailModel.status);
        if (_inProgressForAuthentication()) {
          statusUI = Utils.instance()
              .getUserAuthenStatus(UserAuthStatus.waitingModelFile.get);
        }

        String note = provider.userAuthenDetailModel.note;
        return Visibility(
          visible: provider.userAuthenDetailModel.id != 0,
          child: Container(
            width: w / 3,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusUI.backgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(statusUI.icon, color: statusUI.iconColor, size: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusUI.title,
                      style: TextStyle(
                          color: statusUI.titleColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: w / 3.5,
                      child: Text(
                        note.isNotEmpty &&
                                provider.userAuthenDetailModel.status ==
                                    UserAuthStatus.reject.get
                            ? note
                            : statusUI.description,
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  bool _userHadVideoAuth() {
    UserAuthenDetailModel userDataModel = _provider!.userAuthenDetailModel;

    return userDataModel.id != 0 &&
            File(_provider!.filePathVideo).existsSync() &&
            userDataModel.status == UserAuthStatus.active.get ||
        userDataModel.videosAuthDetail.isNotEmpty;
  }

  bool _inProgressForAuthentication() {
    return _provider!.userAuthenDetailModel.videosAuthDetail.isNotEmpty &&
        _provider!.userAuthenDetailModel.status == UserAuthStatus.draft.get;
  }

  Widget _submitVideoAgainButton() {
    double w = MediaQuery.of(context).size.width;
    return Consumer<UserAuthDetailProvider>(
      builder: (context, provider, child) {
        int statusUser = provider.userAuthenDetailModel.status;
        return Visibility(
            visible: _canStartRecord(statusUser),
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                if (provider
                    .userAuthenDetailModel.videosAuthDetail.isNotEmpty) {
                  _showConfirmBeforeRecord();
                } else {
                  CameraService.instance()
                      .initializeCamera(provider: _cameraPreviewProvider!);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (builder) {
                      return ChangeNotifierProvider(
                        create: (_) => RecordVideoProvider(),
                        child: RecordVideoAuthDialog(
                          cameraPreviewProvider: _cameraPreviewProvider!,
                          userAuthDetailProvider: _provider!,
                        ),
                      );
                    },
                  );
                }
              },
              child: Container(
                width: w / 4,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    color: provider
                            .userAuthenDetailModel.videosAuthDetail.isNotEmpty
                        ? AppColors.defaultYellowColor
                        : AppColors.defaultPurpleColor,
                    borderRadius: BorderRadius.circular(100)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        provider.userAuthenDetailModel.videosAuthDetail
                                .isNotEmpty
                            ? Icons.refresh
                            : Icons.video_camera_front_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                          provider.userAuthenDetailModel.videosAuthDetail
                                  .isNotEmpty
                              ? StringConstants.record_video_again_title
                              : StringConstants
                                  .record_video_authentication_title,
                          style: const TextStyle(
                              color: AppColors.defaultWhiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }

  bool _canStartRecord(int status) {
    return status == UserAuthStatus.reject.get ||
        status == UserAuthStatus.lock.get ||
        status == UserAuthStatus.errorAuth.get ||
        status == UserAuthStatus.draft.get;
  }

  void _showConfirmBeforeRecord() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builderContext) {
        return ConfirmDialogWidget(
          title: StringConstants.waiting_review_video,
          message: StringConstants.confirm_record_new_video,
          cancelButtonTitle: StringConstants.cancel_button_title,
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTapped: () {},
          okButtonTapped: () {
            CameraService.instance()
                .initializeCamera(provider: _cameraPreviewProvider!);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (builder) {
                return ChangeNotifierProvider(
                  create: (_) => RecordVideoProvider(),
                  child: RecordVideoAuthDialog(
                    cameraPreviewProvider: _cameraPreviewProvider!,
                    userAuthDetailProvider: _provider!,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void getUserAuthDetailFail(String message) {
    _circleLoading!.hide();
    _provider!.setStartGetUserAuthDetail(false);
    showDialog(
      context: context,
      builder: (builder) {
        return MessageDialog(context: context, message: message);
      },
    );
  }

  @override
  void getUserAuthDetailSuccess(UserAuthenDetailModel userAuthenDetailModel) {
    _provider!.setStartGetUserAuthDetail(false);
    _provider!.setUserAuthenModel(userAuthenDetailModel);

    String fileName = userAuthenDetailModel.videosAuthDetail.last.url;
    String url = fileEP(fileName);
    print('url:$url');
    _authDetailPresenter!.downloadVideoAuth(fileName, url);
  }

  @override
  void userNotFoundWhenLoadAuth(String message) {
    _circleLoading!.hide();
    _provider!.setStartGetUserAuthDetail(false);
  }

  @override
  void downloadVideoFail(AlertInfo alertInfo) {
    _circleLoading?.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });
  }

  @override
  void downloadVideoSuccess(String savePath) {
    print("savePath: $savePath");
    _circleLoading?.hide();
    _provider!.setFileVideoAuth(savePath);
  }
}
