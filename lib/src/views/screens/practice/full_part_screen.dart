import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/app_colors.dart';
import '../../../models/practice_model/ielts_topic_model.dart';
import '../../../presenters/ielts_topics_list_presenter.dart';
import '../../../providers/practice_screen_provider.dart';
import '../../../utils/navigations.dart';
import '../../../utils/utils.dart';
import '../../dialogs/message_alert.dart';

class FullPartScreen extends StatefulWidget {
  PracticeScreenProvider provider;

  FullPartScreen({required this.provider, super.key});

  @override
  State<FullPartScreen> createState() => _FullPartScreenState();
}

class _FullPartScreenState extends State<FullPartScreen>
    implements IELTSTopicsListConstract {
  IELTSTopicsListPresenter? _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = IELTSTopicsListPresenter(this);
  }

  @override
  Widget build(BuildContext context) {
    return _buildTopicPanel();
  }

  Widget _buildTopicPanel() {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      var topicsPart1 = appState.topicFull1;
      var topiccPart23 = appState.topicFull23;
      var topicsPart1Selected = appState.topicsPartFull1Selected;
      var topicsPart23Selected = appState.topicsPartFull23Selected;
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              width: Utils.instance().getDevicesWidth(context) * 0.45 - 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.defaultWhiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40, bottom: 5),
                      child: GestureDetector(
                        onTap: () {
                          if (topicsPart1Selected.length < topicsPart1.length) {
                            appState.setTopicsPartFull1Selected(topicsPart1);
                          } else {
                            appState.clearTopicsSelectedPartFull1();
                          }

                          if (topicsPart23Selected.length <
                              topiccPart23.length) {
                            appState.setTopicsPartFull23Selected(topiccPart23);
                          } else {
                            appState.clearTopicsSelectedPartFull23();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                topicsPart1Selected.length ==
                                            topicsPart1.length &&
                                        topicsPart23Selected.length ==
                                            topiccPart23.length
                                    ? const Icon(Icons.check_box_rounded,
                                        color: AppColors.defaultPurpleColor)
                                    : const Icon(Icons.check_box_outline_blank,
                                        color: AppColors.defaultPurpleColor),
                                const Text(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                appState.clearTopicsSelectedPartFull1();
                                appState.clearTopicsSelectedPartFull23();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: AppColors.defaultPurpleColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  Utils.instance().multiLanguage(
                                      StringConstants.clear_button_title),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //divider
                    const Divider(
                      height: 1.5,
                      color: AppColors.defaultPurpleColor,
                      thickness: 1.5,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //list topics
                    SizedBox(
                        height: Utils.instance().getDevicesHeight(context) / 2,
                        child: Row(
                          children: [
                            Expanded(
                                child: _buildEachTopics(
                                    Utils.instance().multiLanguage(
                                        StringConstants.topic_part1_title),
                                    IELTSTestOption.part1.get)),
                            Expanded(
                                child: _buildEachTopics(
                                    Utils.instance().multiLanguage(
                                        StringConstants.topic_part23_title),
                                    IELTSTestOption.part2and3.get)),
                          ],
                        )),

                    const SizedBox(height: 5),
                    _buildStartBtn()
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEachTopics(String title, int testOption) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      var topics = _getTopics(testOption);
      Future.delayed(Duration.zero, () {
        if (topics.isEmpty) {
          List<String> topicType = _getTopicType(testOption);
          _presenter!.getIELTSTopicsList(topicType, IELTSStatus.eachPart.get,
              topicOption: testOption);
        }
      });
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$title ${Utils.instance().multiLanguage(StringConstants.selected)}: '
            '(${_getTopicsSelected(testOption).length}/'
            '${_getTopics(testOption).length})',
            style: const TextStyle(
                color: AppColors.defaultPurpleColor,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: topics.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        return _buildCheckTopicBtn(
                            topic: topics.elementAt(index),
                            testOption: testOption);
                      })
                  : _topicsPlaceholder())
        ],
      );
    });
  }

  Widget _topicsPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.defaultGraySlightColor,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(right: 20, top: 10),
      child: Shimmer.fromColors(
          baseColor: AppColors.white,
          highlightColor: AppColors.defaultPurpleSightColor,
          enabled: true,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                for (int i = 0; i < 10; i++)
                  Container(
                    width: 150,
                    height: 30,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  )
              ],
            ),
          )),
    );
  }

  Widget _buildCheckTopicBtn(
      {required IELTSTopicModel topic, required int testOption}) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: GestureDetector(
          onTap: () {
            var topicsSelected = _getTopicsSelected(testOption);
            if (topicsSelected.contains(topic)) {
              _removeTopic(topic, testOption);
            } else {
              _addTopic(topic, testOption);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getTopicsSelected(testOption).contains(topic)
                  ? const Icon(Icons.check_box_rounded,
                      color: AppColors.defaultPurpleColor)
                  : const Icon(Icons.check_box_outline_blank,
                      color: AppColors.defaultPurpleColor),
              const SizedBox(width: 5),
              SizedBox(
                  width: 250,
                  child: Text(
                    topic.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    softWrap: true,
                  )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStartBtn() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.defaultPurpleColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 15,
      ),
      child: TextButton(
        onPressed: () {
          _onClickStart();
        },
        child: Text(
          Utils.instance().multiLanguage(StringConstants.start_title),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.defaultWhiteColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void _onClickStart() {
    var topicsPart1Selected = widget.provider.topicsPartFull1Selected;
    var topicsPart23Selected = widget.provider.topicsPartFull23Selected;

    if (topicsPart1Selected.length < 3) {
      showDialog(
          context: context,
          builder: (context) {
            return MessageDialog(
                context: context,
                message: Utils.instance().multiLanguage(
                    StringConstants.you_must_choose_min_3_topics_part1));
          });
      return;
    }

    if (topicsPart23Selected.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return MessageDialog(
                context: context,
                message: Utils.instance().multiLanguage(
                    StringConstants.you_must_choose_min_1_topics_part23));
          });
      return;
    }

    List<int> topicsId = [];

    for (int i = 0; i < topicsPart1Selected.length; i++) {
      topicsId.add(topicsPart1Selected.elementAt(i).id);
    }
    for (int i = 0; i < topicsPart23Selected.length; i++) {
      topicsId.add(topicsPart23Selected.elementAt(i).id);
    }
    Navigations.instance().goToSimulatorTestRoom(context,
        isPredict: IELTSPredict.normalQuestion.get,
        testOption: IELTSTestOption.full.get,
        topicsId: topicsId);
  }

  Set<IELTSTopicModel> _getTopics(int testOption) {
    return testOption == IELTSTestOption.part1.get
        ? widget.provider.topicFull1
        : widget.provider.topicFull23;
  }

  Set<IELTSTopicModel> _getTopicsSelected(int testOption) {
    return testOption == IELTSTestOption.part1.get
        ? widget.provider.topicsPartFull1Selected
        : widget.provider.topicsPartFull23Selected;
  }

  List<String> _getTopicType(int testOption) {
    return testOption == IELTSTestOption.part1.get
        ? IELTSTopicType.part1.get
        : IELTSTopicType.part2and3.get;
  }

  void _removeTopic(IELTSTopicModel topic, int testOption) {
    if (testOption == IELTSTestOption.part1.get) {
      widget.provider.removeTopicPartFull1(topic);
    } else {
      widget.provider.removeTopicPartFull23(topic);
    }
  }

  void _addTopic(IELTSTopicModel topic, int testOption) {
    if (testOption == IELTSTestOption.part1.get) {
      widget.provider.addTopicsPartFull1(topic);
    } else {
      widget.provider.addTopicsPartFull23(topic);
    }
  }

  bool isShowDialog = true;

  @override
  void getIELTSTopicsFail(String message) {
    if (isShowDialog) {
      showDialog(
          context: context,
          builder: (context) {
            return MessageDialog(context: context, message: message);
          });
      isShowDialog = false;
    }
  }

  @override
  void getIELTSTopicsSuccess(
      List<IELTSTopicModel> topicsList, int? topicOption) {
    if (topicOption != null) {
      if (topicOption == IELTSTestOption.part1.get) {
        widget.provider.setTopicPartFull1(topicsList.toSet());
        widget.provider.setTopicsPartFull1Selected(topicsList.toSet());
      } else {
        widget.provider.setTopicPartFull23(topicsList.toSet());
        widget.provider.setTopicsPartFull23Selected(topicsList.toSet());
      }
    }
  }
}
