import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/my_practice_test_model/my_practice_response_model.dart';
import 'package:icorrect_pc/src/views/widgets/no_data_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../models/my_practice_test_model/my_practice_test_model.dart';
import '../../../presenters/my_tests_list_presenter.dart';
import '../../../providers/my_practice_tests_provider.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';
import '../../dialogs/custom_alert_dialog.dart';
import '../../dialogs/message_alert.dart';
import '../../widgets/grid_view_widget.dart';
import '../../widgets/nothing_widget.dart';

class MyPracticeTests extends StatefulWidget {
  const MyPracticeTests({super.key});

  @override
  State<MyPracticeTests> createState() => _MyPracticeTestsState();
}

class _MyPracticeTestsState extends State<MyPracticeTests>
    implements MyTestsListConstract {
  double w = 0, h = 0;
  MyTestsListPresenter? _presenter;
  MyPracticeTestsProvider? _provider;
  CircleLoading? _loading;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
    _presenter = MyTestsListPresenter(this);
    _provider = Provider.of<MyPracticeTestsProvider>(context, listen: false);
    _getMyTestsList(pageNum: 1);
  }

  void _getMyTestsList({required int pageNum}) {
    _presenter!.getMyTestLists(pageNum: pageNum, isLoadMore: false);
    Future.delayed(Duration.zero, () {
      _provider!.setLoading(true);
      _provider!.clearMyTestsList();
      _provider!.setCurrentPage(pageNum);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loading!.hide();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width / 2;
    h = MediaQuery.of(context).size.height / 1.8;
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        decoration: BoxDecoration(
            color: AppColors.opacity,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.defaultPurpleColor, width: 2)),
        child: Column(
          children: [
            Expanded(
                flex: 3,
                child: Consumer<MyPracticeTestsProvider>(
                    builder: (context, provider, child) {
                  return provider.isLoading
                      ? _myTestPlaceholder()
                      : (provider.myTestsList.isNotEmpty)
                          ? _buildMyPracticesForAllLayout(provider.myTestsList)
                          : NothingWidget.init().buildNothingWidget(
                              Utils.instance().multiLanguage(
                                  StringConstants.no_data_message),
                              widthSize: 180,
                              heightSize: 180);
                })),
            Expanded(flex: 1, child: _buildPagesSelection())
          ],
        ));
  }

  Widget _buildMyPracticesForAllLayout(List<MyPracticeTestModel> list) {
    return (w * 2 < SizeLayout.MyTestScreenSize)
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _myTestItem(list.elementAt(index), index);
            })
        : MyGridView(
            data: list,
            itemWidget: (dynamic itemModel, int index) {
              MyPracticeTestModel myTestModel = itemModel;
              return _myTestItem(myTestModel, index);
            });
  }

  Widget _myTestItem(MyPracticeTestModel myTestModel, int index) {
    Map<String, String> dataString = _getMyTestItem(myTestModel.type);
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.defaultPurpleColor, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: CustomSize.size_50,
                height: CustomSize.size_50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.0,
                    color: AppColors.defaultPurpleColor,
                  ),
                  borderRadius: BorderRadius.circular(CustomSize.size_100),
                ),
                child: Text(
                  dataString[StringConstants.k_data] ?? "I",
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColors.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataString[StringConstants.k_title] ?? "",
                    style: CustomTextStyle.textWithCustomInfo(
                      context: context,
                      color: AppColors.defaultPurpleColor,
                      fontsSize: FontsSize.fontSize_16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.av_timer, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        "00:0${myTestModel.duration}",
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColors.defaultGrayColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getDate(myTestModel.createdAt),
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColors.defaultGrayColor,
                  fontsSize: FontsSize.fontSize_15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {
                  _onClickDeleteTest(myTestModel.id, index);
                },
                child: Text(
                  Utils.instance()
                      .multiLanguage(StringConstants.delete_action_title),
                  style: CustomTextStyle.textWithCustomInfo(
                    context: context,
                    color: AppColors.defaultPurpleColor,
                    fontsSize: FontsSize.fontSize_16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Map<String, String> _getMyTestItem(int type) {
    switch (type) {
      case 1:
        return {
          StringConstants.k_title: "Practice Part I",
          StringConstants.k_data: "I"
        };
      case 2:
        return {
          StringConstants.k_title: "Practice Part II",
          StringConstants.k_data: "II"
        };
      case 3:
        return {
          StringConstants.k_title: "Practice Part III",
          StringConstants.k_data: "III"
        };
      case 4:
        return {
          StringConstants.k_title: "Practice Part II & III",
          StringConstants.k_data: "II&&III"
        };
      case 5:
        return {
          StringConstants.k_title: "Practice Full Test",
          StringConstants.k_data: "FULL"
        };
      default:
        return {
          StringConstants.k_title: "Practice Part I",
          StringConstants.k_data: "I"
        };
    }
  }

  String _getDate(String dateTime) {
    var date = DateTime.parse(dateTime);
    return "${date.day}-${date.month}-${date.year}";
  }

  final ScrollController _scrollController = ScrollController();

  Widget _buildPagesSelection() {
    return Consumer<MyPracticeTestsProvider>(
        builder: (context, provider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              int previousPage = _provider!.currentPage - 1;
              if (previousPage > 0 && !provider.isLoading) {
                _getMyTestsList(pageNum: previousPage);
              }
            },
            child: _pageItem(Utils.instance()
                .multiLanguage(StringConstants.previous_button_title)),
          ),
          Container(
            width: w / 2,
            height: 100,
            alignment: Alignment.center,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final newScrollOffset =
                    _scrollController.offset - (details.delta.dx * 2);
                _scrollController.jumpTo(newScrollOffset);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: List.generate(provider.totalPage, (index) {
                    return InkWell(
                      onTap: () {
                        _getMyTestsList(pageNum: index + 1);
                      },
                      child: _pageItem('${index + 1}', index: index + 1),
                    );
                  }),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              int nextPage = _provider!.currentPage + 1;
              if (nextPage <= _provider!.totalPage && !provider.isLoading) {
                _getMyTestsList(pageNum: nextPage);
              }
            },
            child: _pageItem(Utils.instance()
                .multiLanguage(StringConstants.next_button_title)),
          )
        ],
      );
    });
  }

  Widget _pageItem(String item, {int? index}) {
    var backgroundColor = Colors.white;
    var textColor = AppColors.defaultPurpleColor;
    return Consumer<MyPracticeTestsProvider>(
        builder: (context, provider, child) {
      if (index != null && provider.currentPage == index) {
        backgroundColor = AppColors.defaultPurpleColor;
        textColor = Colors.white;
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: AppColors.defaultPurpleColor, width: 1),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          item,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    });
  }

  void _onClickDeleteTest(int testId, int indexDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: Utils.instance().multiLanguage(StringConstants.dialog_title),
          description: Utils.instance()
              .multiLanguage(StringConstants.delete_this_test_confirm),
          okButtonTitle: StringConstants.ok_button_title,
          cancelButtonTitle: StringConstants.cancel_button_title,
          borderRadius: 8,
          hasCloseButton: true,
          okButtonTapped: () {
            _loading!.show(context);
            _presenter!.deleteTest(testId: testId, index: indexDelete);
          },
          cancelButtonTapped: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _myTestPlaceholder() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.defaultGraySlightColor,
          borderRadius: BorderRadius.circular(10)),
      child: Shimmer.fromColors(
          baseColor: AppColors.white,
          highlightColor: AppColors.defaultPurpleSightColor,
          enabled: true,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: MyGridView(
                data: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
                itemWidget: (dynamic itemModel, int index) {
                  return Container(
                    width: w / 2,
                    height: h / 7,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  );
                }),
          )),
    );
  }

  @override
  void deleteTestFail(String message) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void deleteTestSuccess(String message, int indexDeleted) {
    _loading!.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
    _provider!.removeTestAt(indexDeleted);
  }

  @override
  void getMyTestListFail(String message) {
    _provider!.setLoading(false);
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void getMyTestsListSuccess(MyPracticeResponseModel practiceResponseModel,
      List<MyPracticeTestModel> practiceTests, bool isLoadMore) {
    _provider!.setLoading(false);
    _provider!.setMyTestsList(practiceTests);
    _provider!.setTotalPage(practiceResponseModel.myPracticeDataModel.lastPage);
    _provider!.setMyPracticeResponseModel(practiceResponseModel);
  }
}
