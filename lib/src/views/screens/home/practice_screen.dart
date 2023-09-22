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
    'Music',
    'Weather',
    'Shopping',
    'Environment',
    'Advertising',
    'Books and Films',
    'Sleep',
    'Accommodation',
    'Clothes and Fashion',
    'People — Personality and Character',
    'Business',
    'People — Physical Appearance',
    'Towns and Cities',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utils.instance().getDevicesWidth(context) * 0.055,
          vertical: Utils.instance().getDevicesHeight(context) * 0.03,
        ),
        child: Center(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: Utils.instance().getDevicesHeight(context) * 0.05,
                ),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: Utils.instance().getDevicesWidth(context),
                height: Utils.instance().getDevicesHeight(context),
                child: const GridPaper(
                  color: AppColors.purpleSlight,
                  divisions: 1,
                  interval: 200,
                  subdivisions: 10,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Utils.instance().getDevicesWidth(context) * 0.05,
                  vertical: Utils.instance().getDevicesHeight(context) * 0.03,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: Utils.instance().getDevicesHeight(context) * 0.6,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          _buildTopicBackground(),
                          SizedBox(
                            height: Utils.instance().getDevicesHeight(context) *
                                0.8,
                            child: ListView(
                              // physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildPartItem(
                                  title: 'Part I',
                                  content:
                                      'Examiner will ask general questions on familar topic',
                                ),
                                _buildPartItem(
                                  title: 'Part II',
                                  content:
                                      'Test ability to talk about a topic, develop your ideas about a topic and relevant',
                                ),
                                _buildPartItem(
                                  title: 'Part III',
                                  content:
                                      'Examiner will ask you talk about topics and include the point that you can cover',
                                ),
                                _buildPartItem(
                                  title: 'Part II & III',
                                  content:
                                      'You will take test of part II and III with same topic',
                                ),
                                _buildPartItem(
                                  title: 'Full test',
                                  content:
                                      'You will take a full sample test of ielts Speaking test',
                                ),
                              ],
                            ),
                          ),
                          _buildTopicPanel(),
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
    );
  }

  Widget _buildPartItem({required String title, required String content}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          partFocused = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Stack(
          children: [
            _buildPartItemBackground(title: title),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    width: partFocused == title
                        ? Utils.instance().getDevicesWidth(context) * 0.46
                        : Utils.instance().getDevicesWidth(context) * 0.30,
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.defaultWhiteColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        partFocused == title
                            ? const BoxShadow()
                            : BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
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
                  //check all btn
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 5),
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
                    height: Utils.instance().getDevicesHeight(context) * 0.4,
                    child: GridView.builder(
                      itemCount: topics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 5,
                        crossAxisSpacing: 30,
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
      padding: const EdgeInsets.only(bottom: 10),
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
            Text(
              topic,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.clip,
              maxLines: 2,
              softWrap: true,
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
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          child: Container(
            width: Utils.instance().getDevicesWidth(context) * 0.45,
            height: 82,
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
            borderRadius: BorderRadius.circular(7),
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
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
