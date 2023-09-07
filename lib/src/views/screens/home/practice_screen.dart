import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String partFocused = 'Part I';
  Set<String> checkedTopics = {};
  Set<String> topics = {
    'Animals',
    'Routines',
    'Books',
    'Cleanliness',
    'Clothing',
    'Culture',
    'Exercise',
    'Family',
    'Fears',
    'Goals',
    'Hobbies',
    'Feelings',
    'Hometown',
    'Household Items',
    'Holidays',
    'Relationships',
    'Technology',
    'Sport',
    'Food',
    'Jobs',
    'Transportation',
    'Television',
    'Time',
    'Education',
    'Travel',
    'School',
    'Work',
    'Health',
    'Seasons',
    'Movies',
    'Books and Films',
    'Sleep',
    'Accommodation',
    'Clothes and Fashion',
    'People — Personality and Character',
    'Business',
    'People — Physical Appearance',
    'Towns and Cities',
    'Music',
    'Weather',
    'Shopping',
    'Environment',
    'Advertising',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utils.instance().getDevicesWidth(context) * 0.04,
          vertical: Utils.instance().getDevicesHeight(context) * 0.03,
        ),
        child: Center(
          child: Expanded(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical:
                          Utils.instance().getDevicesHeight(context) * 0.05),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.defaultGrayColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(
                          0,
                          2,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  width: Utils.instance().getDevicesWidth(context),
                  height: Utils.instance().getDevicesHeight(context),
                  child: const GridPaper(
                    color: AppColors.defaultGrayColor,
                    divisions: 1,
                    interval: 200,
                    subdivisions: 10,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        Utils.instance().getDevicesWidth(context) * 0.04,
                    vertical: Utils.instance().getDevicesHeight(context) * 0.03,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height:
                            Utils.instance().getDevicesHeight(context) * 0.6,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Expanded(
                              child: _buildTopicBackground(),
                            ),
                            Expanded(
                              child: SizedBox(
                                height:
                                    Utils.instance().getDevicesHeight(context) *
                                        0.8,
                                child: ListView(
                                  children: [
                                    _buildPartItem(
                                        title: 'Part I',
                                        content: 'Part 1 data'),
                                    _buildPartItem(
                                        title: 'Part II',
                                        content: 'Part 1 data'),
                                    _buildPartItem(
                                        title: 'Part III',
                                        content: 'Part 1 data'),
                                    _buildPartItem(
                                        title: 'Part I & II',
                                        content: 'Part 1 data'),
                                    _buildPartItem(
                                        title: 'Part II & III',
                                        content: 'Part 1 data'),
                                    _buildPartItem(
                                        title: 'Part Full',
                                        content: 'Part 1 data'),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildTopicPanel(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      _buildStartBtn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartItem({required String title, required String content}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          partFocused = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Stack(
          children: [
            _buildPartItemBackground(title: title),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: partFocused == title
                        ? Utils.instance().getDevicesWidth(context) * 0.46
                        : Utils.instance().getDevicesWidth(context) * 0.30,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.defaultWhiteColor,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        partFocused == title
                            ? const BoxShadow()
                            : BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(
                                  0,
                                  2,
                                ), // changes position of shadow
                              ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: CustomTextStyle.textBoldBlack_22,
                          ),
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicPanel() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            width: Utils.instance().getDevicesWidth(context) * 0.45 - 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: AppColors.defaultWhiteColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  //check all btn
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            if (checkedTopics.length < topics.length) {
                              checkedTopics.addAll(topics);
                            } else {
                              checkedTopics.clear();
                            }
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          checkedTopics.length == topics.length
                              ? const Icon(Icons.check_box_outlined)
                              : const Icon(Icons.check_box_outline_blank),
                          const Text(
                            'All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                    height: Utils.instance().getDevicesHeight(context) * 0.7,
                    child: GridView.builder(
                      itemCount: topics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 5,
                            crossAxisSpacing: 30
                      ),
                      itemBuilder: (context, index) {
                        return _buildCheckTopicBtn(
                          topic: topics.elementAt(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckTopicBtn({required String topic}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            checkedTopics.contains(topic)
                ? checkedTopics.remove(topic)
                : checkedTopics.add(topic);
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            checkedTopics.contains(topic)
                ? const Icon(Icons.check_box_outlined)
                : const Icon(Icons.check_box_outline_blank),
            Expanded(
              child: Text(
                topic,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.clip,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartItemBackground({required String title}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
          child: Container(
            width: Utils.instance().getDevicesWidth(context) * 0.45,
            height: 100,
            color: partFocused == title
                ? AppColors.defaultPurpleColor
                : Colors.transparent,
          ),
        )
      ],
    );
  }

  Widget _buildTopicBackground() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: Utils.instance().getDevicesWidth(context) * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.defaultPurpleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStartBtn() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.defaultPurpleColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 15,
      ),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Start',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.defaultWhiteColor,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
