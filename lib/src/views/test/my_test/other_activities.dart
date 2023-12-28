import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:provider/provider.dart';

import '../../../data_source/constants.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/user_data_models/user_data_model.dart';
import '../../../presenters/special_homeworks_presenter.dart';
import '../../../providers/my_test_provider.dart';
import '../../../utils/utils.dart';
import '../../widgets/nothing_widget.dart';

class OtherHomeWorks extends StatefulWidget {
  MyTestProvider provider;
  ActivitiesModel homeWorkModel;
  OtherHomeWorks(
      {super.key, required this.provider, required this.homeWorkModel});

  @override
  State<OtherHomeWorks> createState() => _OtherHomeWorksState();
}

class _OtherHomeWorksState extends State<OtherHomeWorks>
    with AutomaticKeepAliveClientMixin<OtherHomeWorks>
    implements SpecialHomeworksContracts {
  double w = 0, h = 0;
  SpecialHomeworksPresenter? _presenter;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = SpecialHomeworksPresenter(this);
    _getOthersHomeWork();
  }

  void _getOthersHomeWork() async {
    UserDataModel userDataModel =
        await Utils.instance().getCurrentUser() ?? UserDataModel();
    Future.delayed(Duration.zero, () {
      List<StudentResultModel> homeWorks = widget.provider.otherLightHomeWorks;

      if (homeWorks.isEmpty) {
        _loading!.show(context);
        _presenter!.getSpecialHomeWorks(
            context: context,
            email: userDataModel.userInfoModel.email.toString(),
            activityId: widget.homeWorkModel.activityId.toString(),
            status: Status.allHomework.get,
            example: Status.others.get);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    super.build(context);
    return _buildHighLightHomeWorks();
  }

  Widget _buildHighLightHomeWorks() {
    return Container(
        margin: const EdgeInsets.only(bottom: 50),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        decoration: BoxDecoration(
            color: AppColors.opacity,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 2)),
        child: Consumer<MyTestProvider>(builder: (context, provider, child) {
          if (provider.otherLightHomeWorks.isNotEmpty) {
            return Center(
                child: (w < SizeLayout.OthersScreenTabletSize)
                    ? _buildOthersTabletLayout(provider.otherLightHomeWorks)
                    : _buildOthersDesktopLayout(provider.otherLightHomeWorks));
          } else {
            return NothingWidget.init().buildNothingWidget(
                Utils.instance()
                    .multiLanguage(StringConstants.nothing_your_homework),
                widthSize: 200,
                heightSize: 200);
          }
        }));
  }

  Widget _buildOthersDesktopLayout(
      List<StudentResultModel> otherLightHomeWorks) {
    return Center(
        child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 8,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      children: otherLightHomeWorks
          .map(
            (data) => _othersItem(data),
          )
          .toList(),
    ));
  }

  Widget _buildOthersTabletLayout(
      List<StudentResultModel> otherLightHomeWorks) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: otherLightHomeWorks.length,
        itemBuilder: (context, index) {
          return _othersItem(otherLightHomeWorks.elementAt(index));
        });
  }

  Widget _othersItem(StudentResultModel results) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Navigations.instance()
            .goToOtherStudentTestScreen(context, results, widget.homeWorkModel);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 2)),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Text(Utils.instance().scoreReponse(results)['score'],
                  style: TextStyle(
                      color: Utils.instance().scoreReponse(results)['color'],
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(0),
                          child: const CircleAvatar(
                            child: Image(
                              image: AssetImage(AppAssets.default_avatar),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Text(results.students!.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 92, 90, 90),
                                fontSize: 16,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(results.activityResult!.name,
                          style: const TextStyle(
                              color: AppColors.purple,
                              fontSize: 17,
                              fontWeight: FontWeight.w500)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              '${Utils.instance().multiLanguage(StringConstants.time)} : ',
                              style: const TextStyle(
                                  color: AppColors.purple,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          Text(results.updateAt.toString(),
                              style: const TextStyle(
                                  color: AppColors.purple,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          )),
    );
  }

  @override
  void getSpecialHomeWork(List<StudentResultModel> studentsResults) {
    widget.provider.setOtherLightHomeWorks(studentsResults);
    _loading!.hide();
  }

  @override
  void getSpecialHomeWorksFail(String message) {
    _loading!.hide();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
