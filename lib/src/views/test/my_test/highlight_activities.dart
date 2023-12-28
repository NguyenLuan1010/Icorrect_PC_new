import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/models/my_test_models/student_result_model.dart';
import 'package:icorrect_pc/src/views/dialogs/circle_loading.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_assets.dart';
import '../../../data_source/constants.dart';
import '../../../models/homework_models/new_api_135/activities_model.dart';
import '../../../models/user_data_models/user_data_model.dart';
import '../../../presenters/special_homeworks_presenter.dart';
import '../../../providers/my_test_provider.dart';
import '../../../utils/utils.dart';
import '../../widgets/nothing_widget.dart';

class HighLightHomeWorks extends StatefulWidget {
  MyTestProvider provider;
  ActivitiesModel homeWorkModel;
  HighLightHomeWorks(
      {super.key, required this.provider, required this.homeWorkModel});

  @override
  State<HighLightHomeWorks> createState() => _HighLightHomeWorksState();
}

class _HighLightHomeWorksState extends State<HighLightHomeWorks>
    with AutomaticKeepAliveClientMixin<HighLightHomeWorks>
    implements SpecialHomeworksContracts {
  SpecialHomeworksPresenter? _presenter;
  CircleLoading? _loading;
  double w = 0, h = 0;
  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = SpecialHomeworksPresenter(this);
    _getHighLightHomeWork();
  }

  void _getHighLightHomeWork() async {
    UserDataModel userDataModel =
        await Utils.instance().getCurrentUser() ?? UserDataModel();
    if (kDebugMode) {
      print(
          "DEBUG: _getHighLightHomeWork ${widget.homeWorkModel.activityId.toString()}");
    }

    Future.delayed(Duration.zero, () {
      List<StudentResultModel> homeWorks = widget.provider.highLightHomeworks;
      if (homeWorks.isEmpty) {
        _loading!.show(context);
        _presenter!.getSpecialHomeWorks(
            context: context,
            email: userDataModel.userInfoModel.email.toString(),
            activityId: widget.homeWorkModel.activityId.toString(),
            status: Status.highLight.get,
            example: Status.highLight.get);
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
          if (provider.highLightHomeworks.isNotEmpty) {
            return Center(
                child: (w < SizeLayout.OthersScreenTabletSize)
                    ? _buildOthersTabletLayout(provider.highLightHomeworks)
                    : _buildHighLightDesktopLayout(
                        provider.highLightHomeworks));
          } else {
            return NothingWidget.init().buildNothingWidget(
                Utils.instance()
                    .multiLanguage(StringConstants.no_highlight_homework),
                widthSize: 200,
                heightSize: 200);
          }
        }));
  }

  Widget _buildHighLightDesktopLayout(List<StudentResultModel> list) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 8,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      children: list
          .map(
            (data) => _highLightItem(data),
          )
          .toList(),
    );
  }

  Widget _buildOthersTabletLayout(List<StudentResultModel> list) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _highLightItem(list.elementAt(index));
        });
  }

  Widget _highLightItem(StudentResultModel results) {
    return Container(
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
        ));
  }

  @override
  void getSpecialHomeWork(List<StudentResultModel> studentsResults) {
    if (kDebugMode) {
      print('DEBUG: getSpecialHomeWork ${studentsResults.length}');
    }
    widget.provider.setHighLightHomeworks(studentsResults);
    _loading!.hide();
  }

  @override
  void getSpecialHomeWorksFail(String message) {
    // TODO: implement getSpecialHomeWorksFail
    _loading!.hide();
  }

  @override
  bool get wantKeepAlive => true;
}
