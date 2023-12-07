import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
import 'package:icorrect_pc/src/models/ui_models/alert_info.dart';
import 'package:icorrect_pc/src/providers/student_test_detail_provider.dart';
import 'package:icorrect_pc/src/views/test/others_test/corrections_student.dart';
import 'package:icorrect_pc/src/views/test/others_test/view_other_student_answers.dart';
import 'package:provider/provider.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../../../../core/app_colors.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/my_test_models/student_result_model.dart';
import '../../../models/ui_models/download_info.dart';
import '../../../presenters/other_test_detail_presenter.dart';
import '../../../providers/my_test_provider.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/default_loading_indicator.dart';
import '../../widgets/download_again_widget.dart';
import '../../widgets/simulator_test_widgets/download_progressing_widget.dart';

class OtherStudentTestScreen extends StatefulWidget {
  StudentResultModel resultModel;
  ActivitiesModel homeWork;
  OtherStudentTestScreen(
      {required this.resultModel, required this.homeWork, super.key});

  @override
  State<OtherStudentTestScreen> createState() => _OtherStudentTestScreenState();
}

class _OtherStudentTestScreenState extends State<OtherStudentTestScreen>
    with TickerProviderStateMixin
    implements OtherTestDetailContract {
  double w = 0;
  double h = 0;
  TabController? _tabController;
  StudentTestProvider? _provider;
  OtherTestDetailPresenter? _presenter;
  CircleLoading? _loading;
  StreamSubscription? connection;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
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
    _loading = CircleLoading();
    _tabController = TabController(length: 2, vsync: this);
    _provider = Provider.of<StudentTestProvider>(context, listen: false);
    _presenter = OtherTestDetailPresenter(this);
    if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();

    _getTestDetail();
  }

  void _getTestDetail() async {
    _loading!.show(context);
    await _presenter!.initializeData();
    _presenter!.getMyTest(context, widget.homeWork.activityId.toString(),
        widget.resultModel.testId.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _presenter!.closeClientRequest();
    _presenter!.resetAutoRequestDownloadTimes();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: w / 4,
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(
                            Icons.keyboard_backspace_sharp,
                            color: AppColors.black,
                          ))),
                  const SizedBox(width: 10),
                  Text(
                    'Student: ${widget.resultModel.students.name}',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 152, 142, 142),
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  )
                ],
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
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
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
    return [
      const Tab(text: 'Test Detail'),
      const Tab(text: 'Corrections'),
    ];
  }

  Widget _buildTabLayoutScreen(final tabs) {
    return Container(
        margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 300),
                child: DefaultTabController(
                    initialIndex: 0,
                    length: 2,
                    child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            border:
                                Border.all(color: AppColors.black, width: 2)),
                        indicatorColor: AppColors.black,
                        labelColor: AppColors.black,
                        unselectedLabelColor: AppColors.black,
                        tabs: tabs)),
              )),
          body: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ViewOtherStudentAnswers(
                    provider: _provider!,
                    activitiesModel: widget.homeWork,
                    testDetailModel: _provider!.currentTestDetail),
                CorrectionsStudent(
                    activitiesModel: widget.homeWork,
                    studentResultModel: widget.resultModel,
                    provider: _provider!)
              ]),
        ));
  }

  Widget _buildDownloadAgain() {
    return Consumer<StudentTestProvider>(builder: (context, provider, child) {
      if (provider.needDownloadAgain) {
        return DownloadAgainWidget(
          onClickTryAgain: () {
            if (_presenter != null) {
              _presenter!.tryAgainToDownload();
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
      _provider!.setGettingTestDetailStatus(false);
      _provider!.setDownloadProgressingStatus(false);
    }
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
      if (null != _presenter!.testDetail && null != _presenter!.filesTopic) {
        updateStatusForReDownload();
        if (null == _presenter!.dio) {
          _presenter!.initializeData();
        }
        _presenter!
            .reDownloadFiles(context, widget.homeWork.activityId.toString());
      }
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

  void updateStatusForReDownload() {
    _provider!.setNeedDownloadAgain(false);
    _provider!.setDownloadProgressingStatus(true);
  }
}
