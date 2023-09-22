import 'dart:collection';

import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/class_model.dart';
import 'package:icorrect_pc/src/models/homework_models/homework_model.dart';
import 'package:icorrect_pc/src/models/homework_models/new_api_135/activities_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/utils/define_object.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/widgets/simulator_test_widget/download_progressing_widget.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';
import '../../../models/homework_models/new_api_135/new_class_model.dart';
import '../../../presenters/home_presenter.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/nothing_widget.dart';

class HomeWorksWidget extends StatefulWidget {
  const HomeWorksWidget({super.key});

  @override
  State<HomeWorksWidget> createState() => _HomeWorksWidgetState();
}

class _HomeWorksWidgetState extends State<HomeWorksWidget>
    implements HomeWorkViewContract {
  late HomeProvider _provider;
  String _choosenStatus = '';

  CircleLoading? _loading;
  late HomeWorkPresenter _presenter;

  final List<String> _statusSelections = [
    'All',
    'Submitted',
    'Corrected',
    'Not Completed',
    'Late',
    'Out of date'
  ];

  @override
  void initState() {
    super.initState();

    _provider = Provider.of<HomeProvider>(context, listen: false);

    _choosenStatus = _statusSelections.first;
    _loading = CircleLoading();

    _loading?.show(context);
    _presenter = HomeWorkPresenter(this);
    _presenter.getListHomeWork();

    Future.delayed(Duration.zero, () {
      _provider.clearData();
    });
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  Widget _buildWidget() {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 170),
                child: Row(
                  children: [_builClassFilter(), _buildStatusFilter()],
                )),
            _buildHomeworkList()
          ],
        ),
      ),
    );
  }

  Widget _builClassFilter() {
    return Expanded(
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Class Filter",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<NewClassModel>(
                value: provider.classSelected,
                items: provider.classesList.map((NewClassModel value) {
                  return DropdownMenuItem<NewClassModel>(
                    value: value,
                    child: Text(
                      value.name,
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (NewClassModel? newValue) {
                  _provider.setClassSelection(newValue!);
                  List<ActivitiesModel> activities =
                      _presenter.filterActivities(newValue.id,
                          provider.activitiesList, provider.statusActivity,_provider.currentTime);
                  _provider.setActivitiesFilter(activities);
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  filled: true,
                  fillColor: AppColors.defaultGraySlightColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.defaultPurpleColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.defaultPurpleColor, width: 1),
                  ),
                ),
              ),
            ],
          ));
    }));
  }

  Widget _buildStatusFilter() {
    return Expanded(
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status Filter',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: provider.statusActivity,
                items: _statusSelections.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _provider.setStatusActivity(newValue!);
                  List<ActivitiesModel> activities =
                      _presenter.filterActivities(provider.classSelected.id,
                          provider.activitiesList, newValue,_provider.currentTime);
                  _provider.setActivitiesFilter(activities);
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  filled: true,
                  fillColor: Colors.grey[200],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.defaultPurpleColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.defaultPurpleColor, width: 1),
                  ),
                ),
              ),
            ],
          ));
    }));
  }

  Widget _buildHomeworkList() {
    double height = 450;
    double w = MediaQuery.of(context).size.width;
    return Container(
        width: w,
        margin: const EdgeInsets.only(top: 20, left: 100, right: 100),
        child: Consumer<HomeProvider>(builder: (context, provider, child) {
          return FDottedLine(
              color: AppColors.defaultPurpleColor,
              strokeWidth: 2.0,
              dottedLength: 10.0,
              width: w,
              space: 6.0,
              corner: FDottedLineCorner.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.purpleSlight2,
                      Color.fromARGB(0, 255, 255, 255),
                      Color.fromARGB(0, 255, 255, 255)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    InkWell(
                        onTap: () {
                          _provider.setStatusActivity("All");
                          _loading?.show(context);
                          _presenter.getListHomeWork();
                        },
                        child: Container(
                          width: 120,
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.refresh_rounded),
                                SizedBox(width: 5),
                                Text('Refresh Data',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 16,
                                    )),
                              ]),
                        )),
                    SingleChildScrollView(
                        child: Container(
                      height: height,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: (provider.activitiesFilter.isNotEmpty)
                          ? Center(
                              child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 7,
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 1,
                              children: provider.activitiesFilter
                                  .map((data) => _questionItem(data))
                                  .toList(),
                            ))
                          : NothingWidget.init().buildNothingWidget(
                              'Nothing your homeworks in here',
                              widthSize: 180,
                              heightSize: 180),
                    ))
                  ],
                ),
              ));
        }));
  }

  Widget _questionItem(ActivitiesModel homeWork) {
    Map<String, dynamic> statusMap =
        Utils.instance().getHomeWorkStatus(homeWork, _provider.currentTime) ??
            {};

    int activityStatus = Utils.instance().getFilterStatus(statusMap['title']);
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: AppColors.purple),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: AppColors.purple),
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Part",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w400,
                            fontSize: 8)),
                    Text(
                        Utils.instance().getPartOfTestWithString(
                            homeWork.activityTestOption),
                        style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      child: Text(homeWork.activityName.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black))),
                  Row(
                    children: [
                      Text(
                          (homeWork.activityEndTime.isNotEmpty)
                              ? homeWork.activityEndTime.toString()
                              : '0000-00-00 00:00',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black)),
                      const Text(' | ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text(_statusOfActivity(homeWork),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _getColor(homeWork),
                          ))
                    ],
                  )
                ],
              ),
            ],
          ),
          (activityStatus == Status.NOT_COMPLETED.get ||
                  activityStatus == Status.OUT_OF_DATE.get)
              ? SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigations.instance()
                          .goToSimulatorTestRoom(context, homeWork);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(AppColors.purple),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("Start"),
                    ),
                  ),
                )
              : SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () {
                        // print('homework id: ${homeWork.id.toString()}');
                        // _provider.setCurrentMainWidget(
                        //     ResultTestWidget(homeWork: homeWork));
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Details"),
                      )),
                )
        ],
      ),
    );
  }

  String _statusOfActivity(ActivitiesModel activitiesModel) {
    String status = Utils.instance()
        .getHomeWorkStatus(activitiesModel, _provider.currentTime)['title'];
    String aiStatus = Utils.instance().haveAiResponse(activitiesModel);
    if (aiStatus.isNotEmpty) {
      return "${status == 'Corrected' ? '$status &' : ''}$aiStatus";
    } else {
      return status;
    }
  }

  Color _getColor(ActivitiesModel activitiesModel) {
    String aiStatus = Utils.instance().haveAiResponse(activitiesModel);
    if (aiStatus.isNotEmpty) {
      return const Color.fromARGB(255, 12, 201, 110);
    } else {
      return Utils.instance().getHomeWorkStatus(activitiesModel,_provider.currentTime)['color'];
    }
  }

  @override
  void onGetListHomeworkComplete(List<ActivitiesModel> homeworks,
      List<NewClassModel> classes, String currrentTime) {
    _provider.setCurrentTime(currrentTime);
    _provider.setActivitiesList(homeworks);
    _provider.setActivitiesFilter(homeworks);

    NewClassModel classModel = NewClassModel();
    classModel.id = 0;
    classModel.name = "All";
    classes.add(classModel);
    _provider.setClassesList(classes);
    _provider.setClassSelection(classModel);
    _loading?.hide();
  }

  @override
  void onGetListHomeworkError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });
    _loading?.hide();
  }

  @override
  void onLogoutComplete() {
    print('onLogoutComplete');
    _loading?.hide();
  }

  @override
  void onLogoutError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });
    _loading?.hide();
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    print('onUpdateCurrentUserInfo');
    _provider.setCurrentUser(userDataModel);
  }
}