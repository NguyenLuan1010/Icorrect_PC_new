import 'dart:async';
import 'dart:collection';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activity_answer_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/models/ui_models/download_info.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/test/simulator_test/test_room_simulator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../data_source/local/file_storage_helper.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../presenters/simulator_test_presenter.dart';
import '../../../providers/simulator_test_provider.dart';
import '../../../providers/test_room_provider.dart';
import '../../dialogs/alert_dialog.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/default_loading_indicator.dart';
import '../../widgets/download_again_widget.dart';
import '../../widgets/simulator_test_widgets/back_button_widget.dart';
import '../../widgets/simulator_test_widgets/download_progressing_widget.dart';
import '../../widgets/simulator_test_widgets/start_now_button_widget.dart';

class SimulatorTestScreen extends StatefulWidget {
  const SimulatorTestScreen({super.key, required this.homeWorkModel});
  final ActivitiesModel homeWorkModel;
  @override
  State<SimulatorTestScreen> createState() => _SimulatorTestScreenState();
}

class _SimulatorTestScreenState extends State<SimulatorTestScreen>
    implements SimulatorTestViewContract, ActionAlertListener {
  SimulatorTestPresenter? _simulatorTestPresenter;

  SimulatorTestProvider? _simulatorTestProvider;

  Permission? _microPermission;
  PermissionStatus _microPermissionStatus = PermissionStatus.denied;

  StreamSubscription? connection;
  bool isOffline = false;

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
    _simulatorTestProvider =
        Provider.of<SimulatorTestProvider>(context, listen: false);
    _simulatorTestPresenter = SimulatorTestPresenter(this);
    _getTestDetail();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              BackButtonWidget(backButtonTapped: _backButtonTapped),
              Text(widget.homeWorkModel.activityName,
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
    connection!.cancel();
    _simulatorTestPresenter!.closeClientRequest();
    _simulatorTestPresenter!.resetAutoRequestDownloadTimes();
    _simulatorTestProvider!.resetAll();
    super.dispose();
  }

  void _backButtonTapped() async {
    //Disable back button when submitting test
    if (_simulatorTestProvider!.submitStatus == SubmitStatus.submitting) {
      if (kDebugMode) {
        print("DEBUG: Status is submitting!");
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
                title: "Notification",
                description: "The test is not completed! Are you sure to quit?",
                okButtonTitle: "OK",
                cancelButtonTitle: "Cancel",
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
                title: "Notify",
                description: "Do you want to save this test before quit?",
                okButtonTitle: "Save",
                cancelButtonTitle: "Don't Save",
                borderRadius: 8,
                hasCloseButton: false,
                okButtonTapped: () {
                  //Submit
                  _simulatorTestProvider!
                      .updateSubmitStatus(SubmitStatus.submitting);
                  _simulatorTestPresenter!.submitTest(
                    testId: _simulatorTestProvider!.currentTestDetail.testId
                        .toString(),
                    activityId: widget.homeWorkModel.activityId.toString(),
                    questions: _simulatorTestProvider!.questionList,
                  );
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
            Navigator.of(context).pop();
          }

          break;
        }
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
          showDialog(
              context: context,
              builder: (context) {
                return MessageDialog.alertDialog(
                    context, "Can not delete files!");
              });
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
        return SizedBox(
          child: Stack(
            children: [
              ChangeNotifierProvider(
                create: (_) => TestRoomProvider(),
                child: TestRoomSimulator(
                    activitiesModel: widget.homeWorkModel,
                    testDetailModel: _simulatorTestProvider!.currentTestDetail,
                    simulatorTestPresenter: _simulatorTestPresenter!),
              ),
              Visibility(
                visible: provider.submitStatus == SubmitStatus.submitting,
                child: const DefaultLoadingIndicator(
                  color: AppColors.defaultPurpleColor,
                ),
              ),
            ],
          ),
        );
      }
    });
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
    _simulatorTestPresenter!
        .getTestDetail(widget.homeWorkModel.activityId.toString());
  }

  void _startToDoTest() {
    _simulatorTestProvider!.setStartNowStatus(false);
    _simulatorTestProvider!.setGettingTestDetailStatus(false);

    //Hide Loading view
    _simulatorTestProvider!.setDownloadProgressingStatus(false);

    _simulatorTestProvider!.updateDoingStatus(DoingStatus.doing);
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Notify",
          description: "An error occur. Please check your connection!",
          okButtonTitle: "OK",
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

  @override
  void onDownloadFailure(AlertInfo info) {
    // TODO: implement onDownloadFailure
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
          return MessageDialog.alertDialog(context, message);
        });
  }

  @override
  void onGotoMyTestScreen(ActivityAnswer activityAnswer) {
    if (kDebugMode) {
      print("DEBUG: onGotoMyTestScreen");
    }

    //Update activityAnswer into current homeWorkModel
    widget.homeWorkModel.activityAnswer = activityAnswer;
    Navigations.instance().goToMyTest(context, widget.homeWorkModel);
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
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.fail);
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, msg);
        });
    //Go to MyTest Screen
    Navigator.of(context).pop();
  }

  @override
  void onSubmitTestSuccess(String msg, ActivityAnswer activityAnswer) {
    _simulatorTestProvider!.updateSubmitStatus(SubmitStatus.success);

    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, msg);
        });

    //Go to MyTest Screen
    _simulatorTestPresenter!.gotoMyTestScreen(activityAnswer);
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
        _simulatorTestPresenter!.reDownloadFiles();
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
