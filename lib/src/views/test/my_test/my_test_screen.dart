import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/api_urls.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/presenters/my_test_presenter.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/test/my_test/ai_response_widget.dart';
import 'package:icorrect_pc/src/views/test/my_test/highlight_activities.dart';
import 'package:icorrect_pc/src/views/test/my_test/other_activities.dart';
import 'package:icorrect_pc/src/views/test/my_test/teacher_response.dart';
import 'package:icorrect_pc/src/views/test/my_test/view_my_answers.dart';

import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../../../data_source/constants.dart';
import '../../../models/ui_models/download_info.dart';
import '../../dialogs/alert_dialog.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/default_loading_indicator.dart';
import '../../widgets/download_again_widget.dart';
import '../../widgets/simulator_test_widgets/download_progressing_widget.dart';

class MyTestScreen extends StatefulWidget {
  ActivitiesModel homeWork;

  MyTestScreen({super.key, required this.homeWork});

  @override
  State<MyTestScreen> createState() => _MyTestScreenState();
}

class _MyTestScreenState extends State<MyTestScreen>
    with TickerProviderStateMixin
    implements MyTestContract, ActionAlertListener {
  double w = 0, h = 0;
  TabController? _tabController;
  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  MyTestPresenter? _myTestPresenter;
  StreamSubscription? connection;
  bool isOffline = false;
  MyTestProvider? _provider;
  CircleLoading? _loading;
  int _tabLength = 5;

  @override
  void initState() {
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // when every connection status is changed.
      if (result == ConnectivityResult.none) {
        isOffline = true;
      } else if (result == ConnectivityResult.mobile) {
        isOffline = false;
      } else if (result == ConnectivityResult.wifi) {
        isOffline = false;
      } else if (result == ConnectivityResult.ethernet) {
        isOffline = false;
      } else if (result == ConnectivityResult.bluetooth) {
        isOffline = false;
      }

      if (kDebugMode) {
        print("DEBUG: NO INTERNET === $isOffline");
      }
    });
    super.initState();
    _loading = CircleLoading();
    _myTestPresenter = MyTestPresenter(this);
    _provider = Provider.of<MyTestProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _provider!.clearData();
    });
    _setTabController();
    _getTestDetail();
  }

  void _setTabController() {
    if (widget.homeWork.activityAnswer != null) {
      if (!widget.homeWork.activityAnswer!.hasTeacherResponse()) {
        _tabLength = _tabLength - 1;
      }
    }
    if (!widget.homeWork.haveAIResponse()) {
      _tabLength = _tabLength - 1;
    }
    _tabController = TabController(length: _tabLength, vsync: this);
    if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
  }

  void _getTestDetail() async {
    _loading!.show(context);
    await _myTestPresenter!.initializeData();
    _myTestPresenter!.getMyTest(
        context,
        widget.homeWork.activityAnswer!.activityId.toString(),
        widget.homeWork.activityAnswer!.testId.toString());
  }

  @override
  void dispose() {
    connection!.cancel();
    _myTestPresenter!.closeClientRequest();
    _myTestPresenter!.resetAutoRequestDownloadTimes();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return _buildMyTestScreen();
  }

  Widget _buildMyTestScreen() {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.keyboard_backspace_sharp,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Utils.instance()
                          .multiLanguage(StringConstants.back_button_title),
                      style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [_buildBody(), _buildDownloadAgain()],
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildBody() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      if (kDebugMode) {
        print("DEBUG: MyTest--- build -- buildBody");
      }

      if (provider.isDownloadProgressing) {
        DownloadInfo downloadInfo = DownloadInfo(provider.downloadingIndex,
            provider.downloadingPercent, provider.total);
        return DownloadProgressingWidget(downloadInfo);
      }

      if (provider.isGettingTestDetail) {
        return const DefaultLoadingIndicator(
          color: AppColors.defaultPurpleColor,
        );
      } else {
        return _buildTabLayoutScreen(_getTabs());
      }
    });
  }

  _getTabs() {
    var tabs = [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance()
                .multiLanguage(StringConstants.test_detail_title)),
      ),
    ];
    if (widget.homeWork.activityAnswer != null) {
      if (widget.homeWork.activityAnswer!.hasTeacherResponse()) {
        tabs.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Tab(
              text: Utils.instance()
                  .multiLanguage(StringConstants.response_title)),
        ));
      }
    }
    tabs.addAll([
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance()
                .multiLanguage(StringConstants.highlight_title)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Tab(
            text: Utils.instance().multiLanguage(StringConstants.others_list)),
      )
    ]);
    if (widget.homeWork.haveAIResponse()) {
      tabs.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Tab(
            text: Utils.instance()
                .multiLanguage(StringConstants.ai_response_title)),
      ));
    }
    return tabs;
  }

  Widget _buildTabLayoutScreen(final tabs) {
    return Container(
        margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                margin: EdgeInsets.only(
                    left: 50,
                    right: (w < SizeLayout.MyTestScreenSize) ? 0 : 600),
                child: DefaultTabController(
                    initialIndex: 0,
                    length: _tabLength,
                    child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            border: Border.all(
                                color: AppColors.defaultGrayColor, width: 2)),
                        indicatorColor: AppColors.defaultGrayColor,
                        labelColor: AppColors.defaultGrayColor,
                        unselectedLabelColor: AppColors.defaultGrayColor,
                        tabs: tabs)),
              )),
          body: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ViewMyAnswers(
                    activitiesModel: widget.homeWork,
                    provider: _provider!,
                    testDetailModel: _provider!.currentTestDetail,
                    clickUpdateReanswerCallBack: _onClickUpdateReanswer),
                if (widget.homeWork.activityAnswer != null)
                  if (widget.homeWork.activityAnswer!.hasTeacherResponse())
                    TeacherResponseWidget(widget.homeWork, _provider!),
                HighLightHomeWorks(
                    provider: _provider!, homeWorkModel: widget.homeWork),
                OtherHomeWorks(
                    provider: _provider!, homeWorkModel: widget.homeWork),
                if (widget.homeWork.haveAIResponse())
                  FutureBuilder(
                      future: aiResponseEP(
                          widget.homeWork.activityAnswer!.aiOrder.toString()),
                      builder: (_, snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          return AIResponseWidget(
                            url: snapshot.data ?? '',
                          );
                        }
                        return Text(Utils.instance()
                            .multiLanguage(StringConstants.waiting_for_video));
                      })
              ]),
        ));
  }

  void _onClickUpdateReanswer() {
    _loading!.show(context);
    _myTestPresenter!.updateMyAnswer(
      context: context,
      testId: widget.homeWork.activityAnswer!.testId.toString(),
      activityId: widget.homeWork.activityId.toString(),
      reQuestions: _provider!.reAnswerQuestions,
    );
  }

  Widget _buildDownloadAgain() {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      if (provider.needDownloadAgain) {
        return DownloadAgainWidget(
          onClickTryAgain: () {
            if (_myTestPresenter != null) {
              _myTestPresenter!.tryAgainToDownload();
            }
          },
        );
      } else {
        return const SizedBox();
      }
    });
  }

  @override
  void downloadFilesFail(AlertInfo alertInfo) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });
    _loading!.hide();
  }

  @override
  void finishCountDown() {
    // TODO: implement finishCountDown
  }

  @override
  void getMyTestFail(AlertInfo alertInfo) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(
              context: context, message: alertInfo.description);
        });
    _loading!.hide();
  }

  @override
  void getMyTestSuccess(TestDetailModel testDetailModel,
      List<QuestionTopicModel> questions, int total) {
    _provider!.setCurrentTestDetail(testDetailModel);
    _provider!.setQuestionsList(questions);
    _provider!.setDownloadProgressingStatus(true);
    _provider!.setTotal(total);
    _loading!.hide();
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _loading!.hide();
    _provider!.setTotal(total);
    _provider!.updateDownloadingIndex(index);
    _provider!.updateDownloadingPercent(percent);
    _provider!.setActivityType(testDetail.activityType);

    if (index == total) {
      //Auto start to do test
      _checkPermission();
    }
  }

  void _checkPermission() async {
    if (_microPermission == null) {
      await _initializePermission();
    }

    if (mounted) {
      _requestPermission(_microPermission!, context);
    }
  }

  Future<void> _requestPermission(
      Permission permission, BuildContext context) async {
    _provider!.setPermissionDeniedTime();
    // ignore: unused_local_variable
    final status = await permission.request();
    _listenForPermissionStatus(context);
  }

  void _listenForPermissionStatus(BuildContext context) async {
    if (_microPermission != null) {
      _microPermissionStatus = await _microPermission!.status;

      if (_microPermissionStatus == PermissionStatus.denied) {
        if (_provider!.permissionDeniedTime > 2) {
          _showConfirmDialog();
        }
      } else if (_microPermissionStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else {
        _startToDoTest();
      }
    }
  }

  Future<void> _initializePermission() async {
    _microPermission = Permission.microphone;
  }

  void _showConfirmDialog() {
    if (false == _provider!.dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(
              context,
              AlertClass.microPermissionAlert,
              this,
              keyInfo: StringClass.permissionDenied,
            );
          });
      _provider!.setDialogShowing(true);
    }
  }

  void _startToDoTest() {
    _provider!.setGettingTestDetailStatus(false);
    //Hide Loading view
    _provider!.setDownloadProgressingStatus(false);
    _provider!.updateDoingStatus(DoingStatus.doing);
  }

  @override
  void onReDownload() {
    _provider!.setNeedDownloadAgain(true);
    _provider!.setDownloadProgressingStatus(false);
    _provider!.setGettingTestDetailStatus(false);
  }

  @override
  void onTryAgainToDownload() {
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _myTestPresenter!.testDetail &&
          null != _myTestPresenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _myTestPresenter!.dio) {
          _myTestPresenter!.initializeData();
        }
        _myTestPresenter!.reDownloadFiles(
            context, widget.homeWork.activityAnswer!.activityId.toString());
      }
    }
  }

  void _showCheckNetworkDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.instance().multiLanguage(StringConstants.dialog_title),
          description: Utils.instance()
              .multiLanguage(StringConstants.network_error_message),
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: null,
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            Navigator.of(context).pop();
          },
          cancelButtonTapped: null,
        );
      },
    );
  }

  void updateStatusForReDownload() {
    _provider!.setNeedDownloadAgain(false);
    _provider!.setDownloadProgressingStatus(true);
  }

  @override
  void updateAnswerFail(AlertInfo info) {
    // TODO: implement updateAnswerFail
    _loading!.hide();
  }

  @override
  void updateAnswersSuccess(String message) {
    _loading!.hide();
    _provider!.clearReanswerQuestion();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onAlertExit(String keyInfo) {
    // TODO: implement onAlertExit
  }

  @override
  void onAlertNextStep(String keyInfo) {
    // TODO: implement onAlertNextStep
  }
}
