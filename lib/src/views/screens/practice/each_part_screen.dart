import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/practice_model/ielts_topic_model.dart';
import 'package:icorrect_pc/src/presenters/ielts_topics_list_presenter.dart';
import 'package:icorrect_pc/src/providers/practice_screen_provider.dart';
import 'package:icorrect_pc/src/utils/navigations.dart';
import 'package:icorrect_pc/src/views/widgets/grid_view_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/app_colors.dart';
import '../../../data_source/constants.dart';
import '../../../utils/utils.dart';
import '../../dialogs/message_alert.dart';

class EachPartScreen extends StatefulWidget {
  PracticeScreenProvider provider;
  int testOption;
  EachPartScreen({required this.provider, required this.testOption, super.key});

  @override
  State<EachPartScreen> createState() => _EachPartScreenState();
}

class _EachPartScreenState extends State<EachPartScreen>
    implements IELTSTopicsListConstract {
  double w = 0, h = 0;
  IELTSTopicsListPresenter? _presenter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    return _buildTopicPanel();
  }

  Widget _buildTopicPanel() {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      var topics = _getTopicsList();
      var topicSelected = _getTopicsSelectedList();
      Future.delayed(Duration.zero, () {
        if (topics.isEmpty) {
          List<String> topicType = _getTopicType();
          _presenter = IELTSTopicsListPresenter(this);
          _presenter!.getIELTSTopicsList(topicType, IELTSStatus.eachPart.get);
        }
      });

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
                          var topics = _getTopicsList();
                          var topicSelected = _getTopicsSelectedList();
                          if (topicSelected.length < topics.length) {
                            _addAllTopicsSelected(topics);
                          } else {
                            _clearTopicsSelected();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                topicSelected.length == topics.length
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
                            Text(
                              '${Utils.instance().multiLanguage(StringConstants.select_topic)}'
                              ' (${_getTopicsSelectedList().length}'
                              '/${_getTopicsList().length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (w > SizeLayout.MyTestScreenSize)
                              InkWell(
                                onTap: () {
                                  _clearTopicsSelected();
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                        child: topics.isNotEmpty
                            ? _buildTopicsList(topics)
                            : _topicsPlaceholder()),
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

  Widget _buildTopicsList(Set<IELTSTopicModel> topics) {
    return (w < SizeLayout.MyTestScreenSize)
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return _buildCheckTopicBtn(
                topic: topics.elementAt(index),
              );
            })
        : MyGridView(
            data: topics.toList(),
            itemWidget: (dataModel, index) {
              return _buildCheckTopicBtn(
                topic: topics.elementAt(index),
              );
            });
  }

  Widget _topicsPlaceholder() {
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
            child: Row(
              children: [
                Expanded(
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
                ),
                Expanded(
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
                )
              ],
            ),
          )),
    );
  }

  Widget _buildCheckTopicBtn({required IELTSTopicModel topic}) {
    return Consumer<PracticeScreenProvider>(
        builder: (context, appState, child) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () {
            var topicsSelected = _getTopicsSelectedList();
            if (topicsSelected.contains(topic)) {
              _removeTopicSelected(topic);
            } else {
              _addTopicSelected(topic);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getTopicsSelectedList().contains(topic)
                  ? const Icon(Icons.check_box_rounded,
                      color: AppColors.defaultPurpleColor)
                  : const Icon(Icons.check_box_outline_blank,
                      color: AppColors.defaultPurpleColor),
              const SizedBox(width: 5),
              SizedBox(
                  width: w / 7,
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
          _onClickStartButton();
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

  void _onClickStartButton() {
    var topicSelected = _getTopicsSelectedList();
    if (topicSelected.isNotEmpty) {
      if (topicSelected.length < 3 &&
          widget.testOption != IELTSTestOption.part2and3.get) {
        showDialog(
            context: context,
            builder: (context) {
              return MessageDialog(
                  context: context,
                  message: Utils.instance().multiLanguage(
                      StringConstants.you_must_choose_min_3_topics));
            });
      } else {
        List<int> topicsId = [];
        Set<IELTSTopicModel> topicsSelected = _getTopicsSelectedList();
        for (int i = 0; i < topicsSelected.length; i++) {
          topicsId.add(topicsSelected.elementAt(i).id);
        }
        Navigations.instance().goToSimulatorTestRoom(context,
            isPredict: IELTSPredict.normalQuestion.get,
            testOption: widget.testOption,
            topicsId: topicsId);
      }
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return MessageDialog(
                context: context,
                message: Utils.instance()
                    .multiLanguage(StringConstants.empty_selected_topics));
          });
    }
  }

  List<String> _getTopicType() {
    switch (widget.testOption) {
      case 1: //option part 1
        return IELTSTopicType.part1.get;
      case 2: //option part 2
        return IELTSTopicType.part2.get;
      case 3: //option part 3
        return IELTSTopicType.part3.get;
      case 4: //option part 2 & 3
        return IELTSTopicType.part2and3.get;
      default:
        return [];
    }
  }

  Set<IELTSTopicModel> _getTopicsList() {
    switch (widget.testOption) {
      case 1: //option part 1
        return widget.provider.topicPart1;
      case 2: //option part 2
        return widget.provider.topicPart2;
      case 3: //option part 3
        return widget.provider.topicPart3;
      case 4: //option part 2 & 3
        return widget.provider.topicPart23;
      default:
        return {};
    }
  }

  Set<IELTSTopicModel> _getTopicsSelectedList() {
    switch (widget.testOption) {
      case 1: //option part 1
        return widget.provider.topicsPart1Selected;
      case 2: //option part 2
        return widget.provider.topicsPart2Selected;
      case 3: //option part 3
        return widget.provider.topicsPart3Selected;
      case 4: //option part 2 & 3
        return widget.provider.topicsPart23Selected;
      default:
        return {};
    }
  }

  void _addAllTopicsSelected(Set<IELTSTopicModel> topics) {
    switch (widget.testOption) {
      case 1: //option part 1
        widget.provider.setTopicsPart1Selected(topics);
        break;
      case 2: //option part 2
        widget.provider.setTopicsPart2Selected(topics);
        break;
      case 3: //option part 3
        widget.provider.setTopicsPart3Selected(topics);
        break;
      case 4: //option part 2 & 3
        widget.provider.setTopicsPart23Selected(topics);
        break;
    }
  }

  void _addTopicSelected(IELTSTopicModel topic) {
    switch (widget.testOption) {
      case 1: //option part 1
        widget.provider.addTopicsPart1(topic);
        break;
      case 2: //option part 2
        widget.provider.addTopicsPart2(topic);
        break;
      case 3: //option part 3
        widget.provider.addTopicsPart3(topic);
        break;
      case 4: //option part 2 & 3
        widget.provider.addTopicsPart23(topic);
        break;
    }
  }

  void _addAllTopics(Set<IELTSTopicModel> topics) {
    switch (widget.testOption) {
      case 1: //option part 1
        widget.provider.setTopicPart1(topics);
        break;
      case 2: //option part 2
        widget.provider.setTopicPart2(topics);
        break;
      case 3: //option part 3
        widget.provider.setTopicPart3(topics);
        break;
      case 4: //option part 2 & 3
        widget.provider.setTopicPart23(topics);
        break;
    }
  }

  void _clearTopicsSelected() {
    switch (widget.testOption) {
      case 1: //option part 1
        widget.provider.clearTopicsSelectedPart1();
        break;
      case 2: //option part 2
        widget.provider.clearTopicsSelectedPart2();
        break;
      case 3: //option part 3
        widget.provider.clearTopicsSelectedPart3();
        break;
      case 4: //option part 2 & 3
        widget.provider.clearTopicsSelectedPart23();
        break;
    }
  }

  void _removeTopicSelected(IELTSTopicModel topic) {
    switch (widget.testOption) {
      case 1: //option part 1
        widget.provider.removeTopicPart1(topic);
        break;
      case 2: //option part 2
        widget.provider.removeTopicPart2(topic);
        break;
      case 3: //option part 3
        widget.provider.removeTopicPart3(topic);
        break;
      case 4: //option part 2 & 3
        widget.provider.removeTopicPart23(topic);
        break;
    }
  }

  @override
  void getIELTSTopicsFail(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog(context: context, message: message);
        });
  }

  @override
  void getIELTSTopicsSuccess(
      List<IELTSTopicModel> topicsList, int? topicOption) {
    _addAllTopics(topicsList.toSet());

    _addAllTopicsSelected(_getTopicsList());
  }
}
