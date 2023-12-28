import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/models/ui_models/download_info.dart';
import 'package:icorrect_pc/src/providers/auth_widget_provider.dart';
import 'package:icorrect_pc/src/providers/main_widget_provider.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:icorrect_pc/src/views/screens/home/home_screen.dart';
import 'package:icorrect_pc/src/views/test/my_test/highlight_activities.dart';
import 'package:icorrect_pc/src/views/test/my_test/other_activities.dart';
import 'package:icorrect_pc/src/views/test/simulator_test/test_room_simulator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/camera_service.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../providers/camera_preview_provider.dart';
import '../../../providers/simulator_test_provider.dart';
import '../../../providers/test_room_provider.dart';
import '../../../utils/utils.dart';
import '../../dialogs/alert_dialog.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/default_loading_indicator.dart';
import '../../widgets/download_again_widget.dart';
import '../../widgets/simulator_test_widgets/back_button_widget.dart';
import '../../widgets/simulator_test_widgets/download_progressing_widget.dart';
import '../../widgets/simulator_test_widgets/start_now_button_widget.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen(
      {super.key,
      this.homeWorkModel,
      this.testOption,
      this.topicsId,
      this.isPredict});
  final ActivitiesModel? homeWorkModel;
  final int? testOption;
  final List<int>? topicsId;
  final int? isPredict;
  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    with TickerProviderStateMixin
    implements SimulatorTestViewContract, ActionAlertListener {
  double w = 0;
  double h = 0;
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;
  AuthWidgetProvider? _authWidgetProvider;
  CameraPreviewProvider? _cameraPreviewProvider;

  Permission? _microPermission;
  CircleLoading? _loading;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;
  TabController? _tabController;

  StreamSubscription? connection;
  bool isOffline = false;
  bool _isExam = false;

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

    _tabController = TabController(length: 3, vsync: this);
    _loading = CircleLoading();

    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _cameraPreviewProvider =
        Provider.of<CameraPreviewProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _simulatorTestProvider!.resetAll();
    });
    _authWidgetProvider =
        Provider.of<AuthWidgetProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);

    if (widget.homeWorkModel != null) {
      _isExam = widget.homeWorkModel!.activityType == ActivityType.exam.name ||
          widget.homeWorkModel!.activityType == ActivityType.test.name;
    } else {
      _isExam = false;
    }
    _getTestDetail();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              InkWell(
                onTap: _backButtonTapped,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    color: AppColors.defaultPurpleColor,
                    size: 30,
                  ),
                ),
              ),
              Text(
                  (widget.homeWorkModel != null)
                      ? widget.homeWorkModel!.activityName
                      : "",
                  style: const TextStyle(
                      color: AppColors.defaultPurpleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBody(),
              _buildDownloadAgain(),
            ],
          ),
        ),
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    // CameraService.instance()
    //     .disposeCurrentCamera(provider: _cameraPreviewProvider!);
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
  }

  void _backButtonTapped() async {
    //Disable back button when submitting test
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      if (kDebugMode) {
        print("DEBUG: Status is submitting!");
      }
      return;
    }

    if (_simulatorTestProvider!.submitStatus == SubmitStatus.success) {
      if (_simulatorTestProvider!.reanswersList.isNotEmpty) {
        if (kDebugMode) {
          print("DEBUG: Status is doing the test!");
        }

        bool okButtonTapped = false;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title:
                  Utils.instance().multiLanguage(StringConstants.dialog_title),
              description: Utils.instance().multiLanguage(
                  StringConstants.save_change_before_exit_message),
              okButtonTitle: StringConstants.ok_button_title,
              cancelButtonTitle: Utils.instance()
                  .multiLanguage(StringConstants.cancel_button_title),
              borderRadius: 8,
              hasCloseButton: false,
              okButtonTapped: () {
                okButtonTapped = true;
                _onSubmitTest();
              },
              cancelButtonTapped: () {
                Navigator.of(context).pop();
              },
            );
          },
        );

        if (okButtonTapped) {
          Navigator.of(context).pop();
        }
      } else {
        _authWidgetProvider!.setRefresh(true);
        Navigator.of(context).pop();
      }
      return;
    }

    switch (_simulatorTestProvider!.doingStatus.get) {
      case -1:
        {
          //None
          if (kDebugMode) {
            print("DEBUG: Status is not start to do the test!");
          }
          Navigator.of(context).pop();
          break;
        }
      case 0:
        {
          //Doing
          if (kDebugMode) {
            print("DEBUG: Status is doing the test!");
          }

          bool okButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: Utils.instance()
                    .multiLanguage(StringConstants.dialog_title),
                description: Utils.instance()
                    .multiLanguage(StringConstants.exit_while_testing_confirm),
                okButtonTitle: StringConstants.ok_button_title,
                cancelButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.cancel_button_title),
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () {
                  okButtonTapped = true;
                  _deleteAllAnswer();
                },
                cancelButtonTapped: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );

          if (okButtonTapped) {
            _authWidgetProvider!.setRefresh(_isExam);
            Navigator.of(context).pop();
          }

          break;
        }
      case 1:
        {
          //Finish
          if (kDebugMode) {
            print("DEBUG: Status is finish doing the test!");
          }

          bool cancelButtonTapped = false;

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: Utils.instance()
                    .multiLanguage(StringConstants.dialog_title),
                description: Utils.instance()
                    .multiLanguage(StringConstants.save_before_exit_message),
                okButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.save_button_title),
                cancelButtonTitle: Utils.instance()
                    .multiLanguage(StringConstants.dont_save_button_title),
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () {
                  //Submit
                  _onSubmitTest();
                },
                cancelButtonTapped: () {
                  cancelButtonTapped = true;
                  _deleteAllAnswer();
                  Navigator.of(context).pop();
                },
              );
            },
          );

          if (cancelButtonTapped) {
            _authWidgetProvider!.setRefresh(_isExam);
            Navigator.of(context).pop();
          }

          break;
        }
    }
  }

  Future _onSubmitTest() async {
    _loading!.show(context);

    String activityId = "";
    if (widget.homeWorkModel != null) {
      activityId = widget.homeWorkModel!.activityId.toString();
    }
    if (_simulatorTestProvider!.reanswersList.isNotEmpty) {
      _simulatorTestPresenter!.submitTest(
          context: context,
          testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
          activityId: activityId,
          questions: _simulatorTestProvider!.reanswersList,
          isExam: _isExam,
          isUpdate: true,
          logAction: _simulatorTestProvider!.logActions);
    } else {
      String pathVideo = _simulatorTestPresenter!
          .randomVideoRecordExam(_simulatorTestProvider!.videosRecorded);
      if (kDebugMode) {
        print("RECORDING_VIDEO : Video Recording saved at: $pathVideo");
      }
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.submitting);
      _simulatorTestPresenter!.submitTest(
          context: context,
          testId: _simulatorTestProvider!.currentTestDetail.testId.toString(),
          activityId: activityId,
          questions: _simulatorTestProvider!.questionList,
          isExam: _isExam,
          isUpdate: false,
          videoConfirmFile:
              File(pathVideo).existsSync() ? File(pathVideo) : null,
          logAction: _simulatorTestProvider!.logActions);
    }
  }

  Future<void> _deleteAllAnswer() async {
    List<String> answers = _simulatorTestProvider!.answerList;

    if (answers.isEmpty) return;

    for (String answer in answers) {
      FileStorageHelper.deleteFile(answer, MediaType.audio,
              _simulatorTestProvider!.currentTestDetail.testId.toString())
          .then((value) {
        if (false == value) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return MessageDialog(
          //           context: context, message: "Can not delete files!");
          //     });
        }
      });
    }
  }

  Widget _buildBody() {
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      if (kDebugMode) {
        print("DEBUG: SimulatorTest --- build -- buildBody");
      }

      if (provider.isDownloadProgressing) {
        DownloadInfo downloadInfo = DownloadInfo(provider.downloadingIndex,
            provider.downloadingPercent, provider.total);
        return Column(
          children: [
            DownloadProgressingWidget(downloadInfo),
            Visibility(
              visible: provider.startNowAvailable,
              child: StartNowButtonWidget(
                startNowButtonTapped: () {
                  _checkPermission();
                },
              ),
            ),
          ],
        );
      }

      if (provider.isGettingTestDetail) {
        return const DefaultLoadingIndicator(
          color: AppColors.defaultPurpleColor,
        );
      } else {
        return (provider.submitStatus == SubmitStatus.success &&
                widget.homeWorkModel != null)
            ? Expanded(
                child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 50),
                    child: Scaffold(
                      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(40),
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 50,
                                right: (w < SizeLayout.MyTestScreenSize)
                                    ? 0
                                    : 600),
                            child: DefaultTabController(
                                initialIndex: 0,
                                length: (provider.submitStatus ==
                                        SubmitStatus.success)
                                    ? 3
                                    : 1,
                                child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5)),
                                        border: Border.all(
                                            color: AppColors.black, width: 2)),
                                    indicatorColor: AppColors.black,
                                    labelColor: AppColors.black,
                                    unselectedLabelColor:
                                        AppColors.defaultGrayColor,
                                    tabs: _getTabs())),
                          )),
                      body: TabBarView(
                          controller: _tabController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            TestRoomSimulator(
                              activitiesModel: widget.homeWorkModel,
                              testDetailModel:
                                  _simulatorTestProvider!.currentTestDetail,
                              simulatorTestPresenter: _simulatorTestPresenter!,
                              simulatorTestProvider: _simulatorTestProvider!,
                            ),
                            HighLightHomeWorks(
                                provider: Provider.of<MyTestProvider>(context,
                                    listen: false),
                                homeWorkModel: widget.homeWorkModel!),
                            OtherHomeWorks(
                                provider: Provider.of<MyTestProvider>(context,
                                    listen: false),
                                homeWorkModel: widget.homeWorkModel!)
                          ]),
                    )))
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: TestRoomSimulator(
                  activitiesModel: widget.homeWorkModel,
                  testDetailModel: _simulatorTestProvider!.currentTestDetail,
                  simulatorTestPresenter: _simulatorTestPresenter!,
                  simulatorTestProvider: _simulatorTestProvider!,
                ),
              );
      }
    });
  }

  _getTabs() {
    return [
      Tab(
          text: Utils.instance()
              .multiLanguage(StringConstants.test_detail_title)),
      Tab(
          text:
              Utils.instance().multiLanguage(StringConstants.highlight_title)),
      Tab(text: Utils.instance().multiLanguage(StringConstants.others_list)),
    ];
  }

  Widget _buildDownloadAgain() {
    return Consumer<SimulatorTestProvider>(builder: (context, provider, child) {
      if (provider.needDownloadAgain) {
        return DownloadAgainWidget(
          onClickTryAgain: () {
            if (_simulatorTestPresenter != null) {
              _simulatorTestPresenter!.tryAgainToDownload();
            }
          },
        );
      } else {
        return const SizedBox();
      }
    });
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
    _simulatorTestProvider!.setPermissionDeniedTime();
    // ignore: unused_local_variable
    final status = await permission.request();
    _listenForPermissionStatus(context);
  }

  void _listenForPermissionStatus(BuildContext context) async {
    if (_microPermission != null) {
      _microPermissionStatus = await _microPermission!.status;

      if (_microPermissionStatus == PermissionStatus.denied) {
        if (_simulatorTestProvider!.permissionDeniedTime > 2) {
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

  void _getTestDetail() async {
    await _simulatorTestPresenter!.initializeData();
    if (widget.homeWorkModel != null) {
      _simulatorTestPresenter!.getTestDetailByHomework(
          context, widget.homeWorkModel!.activityId.toString());
    } else {
      _simulatorTestPresenter!.getTestDetailByPractice(
          context: context,
          testOption: widget.testOption ?? 0,
          topicsId: widget.topicsId ?? [],
          isPredict: widget.isPredict ?? 0);
    }
  }

  void _startToDoTest() {
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
  }

  void _showConfirmDialog() {
    if (false == _simulatorTestProvider!.dialogShowing) {
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
      _simulatorTestProvider!.setDialogShowing(true);
    }
  }

  void _showCheckNetworkDialog() async {
    bool okButtonTapped = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.instance().multiLanguage(StringConstants.warning_title),
          description: Utils.instance()
              .multiLanguage(StringConstants.network_error_message),
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: Utils.instance()
              .multiLanguage(StringConstants.cancel_button_title),
          borderRadius: 8,
          hasCloseButton: false,
          okButtonTapped: () {
            okButtonTapped = true;
            _simulatorTestPresenter!.tryAgainToDownload();
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );

    if (okButtonTapped) {
      _authWidgetProvider!.setRefresh(_isExam);
      Navigator.of(context).pop();
    }
  }

  @override
  Future<void> onDownloadingFile() async {
    if (isOffline) {
      _showCheckNetworkDialog();
    }
  }

  @override
  void onDownloadFailure(AlertInfo info) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: info.description);
        });
  }

  @override
  void onDownloadSuccess(TestDetailModel testDetail, String nameFile,
      double percent, int index, int total) {
    _simulatorTestProvider!.setTotal(total);
    _simulatorTestProvider!.updateDownloadingIndex(index);
    _simulatorTestProvider!.updateDownloadingPercent(percent);
    _simulatorTestProvider!.setActivityType(testDetail.activityType);

    //Enable Start Testing Button
    if (index >= 5) {
      _simulatorTestProvider!.setStartNowStatus(true);
    }

    if (index == total) {
      //Auto start to do test
      _checkPermission();
    }
  }

  @override
  void onGetTestDetailComplete(TestDetailModel testDetailModel, int total) {
    _simulatorTestProvider!.setCurrentTestDetail(testDetailModel);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
    _simulatorTestProvider!.setTotal(total);
  }

  @override
  void onGetTestDetailError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void onGotoMyTestScreen(ActivityAnswer activityAnswer) {
    if (kDebugMode) {
      print("DEBUG: onGotoMyTestScreen");
    }

    //Update activityAnswer into current homeWorkModel
    if (widget.homeWorkModel != null) {
      widget.homeWorkModel!.activityAnswer = activityAnswer;
      Navigations.instance().goToMyTest(context, widget.homeWorkModel!);
    }
  }

  @override
  void onHandleBackButtonSystemTapped() {
    // TODO: implement onHandleBackButtonSystemTapped
  }

  @override
  void onHandleEventBackButtonSystem({required bool isQuitTheTest}) {
    if (kDebugMode) {
      print(
          "DEBUG: _handleEventBackButtonSystem - quit this test = $isQuitTheTest");
    }

    if (isQuitTheTest) {
      _deleteAllAnswer();
      Navigator.of(context).pop();
    } else {
      //Continue play video
    }
  }

  @override
  void onReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(true);
    _simulatorTestProvider!.setDownloadProgressingStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);
  }

  @override
  void onSaveTopicListIntoProvider(List<TopicModel> list) {
    _simulatorTestProvider!.setTopicsList(list);
    Queue<TopicModel> queue = Queue<TopicModel>();
    queue.addAll(list);
    _simulatorTestProvider!.setTopicsQueue(queue);
  }

  @override
  void onSubmitTestFail(String msg) {
    Utils.instance().sendLog();
    _loading!.hide();
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
    //Go to MyTest Screen
    // Navigator.of(context).pop();
  }

  @override
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer) {
    Utils.instance().sendLog();
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: msg);
        });
    if (mounted) {
      // _authWidgetProvider!.setRefresh(true);
      _simulatorTestProvider!.setVisibleSaveTheTest(false);
      _simulatorTestProvider!.clearReasnwersList();
      _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);
    }
    // //Go to MyTest Screen
    // _simulatorTestPresenter!.gotoMyTestScreen(activityAnswer);
    // Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  void onTryAgainToDownload() {
    if (isOffline) {
      _showCheckNetworkDialog();
    } else {
      if (null != _simulatorTestPresenter!.testDetail &&
          null != _simulatorTestPresenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _simulatorTestPresenter!.dio) {
          _simulatorTestPresenter!.initializeData();
        }
        String? activityId;
        if (widget.homeWorkModel != null) {
          activityId = widget.homeWorkModel!.activityId.toString();
        }
        _simulatorTestPresenter!
            .reDownloadFiles(context, activityId: activityId);
      }
    }
  }

  void updateStatusForReDownload() {
    _simulatorTestProvider!.setNeedDownloadAgain(false);
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setDownloadProgressingStatus(true);
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
