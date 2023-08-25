import 'dart:collection';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/homework_models/class_model.dart';
import 'package:icorrect_pc/src/models/homework_models/homework_model.dart';
import 'package:icorrect_pc/src/models/user_data_models/user_data_model.dart';
import 'package:icorrect_pc/src/providers/home_provider.dart';
import 'package:icorrect_pc/src/utils/define_object.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_colors.dart';
import '../../../presenters/home_presenter.dart';
import '../../../utils/utils.dart';
import '../../dialogs/circle_loading.dart';

class HomeWorksWidget extends StatefulWidget {
  const HomeWorksWidget({super.key});

  @override
  State<HomeWorksWidget> createState() => _HomeWorksWidgetState();
}

class _HomeWorksWidgetState extends State<HomeWorksWidget>
    implements HomeWorkViewContract {
  late HomeProvider _provider;
  String _choosenClass = '';
  String _choosenStatus = '';

  CircleLoading? _loading;
  late HomeWorkPresenter _presenter;

  List<String> _classSelections = ['Alls'];
  final List<String> _statusSelections = [
    'Alls',
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
    _choosenClass = _classSelections.first;
    _choosenStatus = _statusSelections.first;
    _loading = CircleLoading();

    _loading?.show(context);
    _presenter = HomeWorkPresenter(this);
    _presenter.getListHomeWork();
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
            LayoutBuilder(builder: (context, contraints) {
              if (contraints.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      _buildClassFilterMobile(_classSelections),
                      const SizedBox(height: 10),
                      _buildStatusFilterMobile()
                    ],
                  ),
                );
              } else {
                return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 170),
                    child: Row(
                      children: [
                        _builClassFilterDesktop(_classSelections),
                        _buildStatusFilterDesktop()
                      ],
                    ));
              }
            }),
            LayoutBuilder(builder: (context, contraints) {
              if (contraints.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
                return _buildHomeworkListMobile();
              } else {
                return _buildHomeworkListDesktop();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildClassFilterMobile(List<String> classSelections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Class Filter",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _choosenClass,
          items: classSelections.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // if (mounted) {
            //   setState(() {
            //     _choosenClass = newValue ?? '';
            //     int status = _getFilterStatus(_choosenStatus);
            //     if (_homeworks.isNotEmpty) {
            //       _filterHomeWorks = _presenter.filterHomeWorks(
            //           _choosenClass, status, _homeworks);
            //     }
            //   });
            // }
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Status Filter",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _choosenStatus,
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
            // if (mounted) {
            //   setState(() {
            //     _choosenStatus = newValue ?? '';
            //     int status = _getFilterStatus(_choosenStatus);
            //     if (_homeworks.isNotEmpty) {
            //       _filterHomeWorks = _presenter.filterHomeWorks(
            //           _choosenClass, status, _homeworks);
            //     }
            //   });
            // }
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _builClassFilterDesktop(List<String> classSelections) {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Class Filter",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _choosenClass,
                  items: classSelections.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // if (mounted) {
                    //   setState(() {
                    //     _choosenClass = newValue ?? '';
                    //     int status = _getFilterStatus(_choosenStatus);
                    //     if (_homeworks.isNotEmpty) {
                    //       _filterHomeWorks = _presenter.filterHomeWorks(
                    //           _choosenClass, status, _homeworks);
                    //     }
                    //   });
                    // }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildStatusFilterDesktop() {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Filter',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _choosenStatus,
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
                    // if (mounted) {
                    //   setState(() {
                    //     _choosenStatus = newValue ?? '';
                    //     int status = _getFilterStatus(_choosenStatus);
                    //     if (_homeworks.isNotEmpty) {
                    //       _filterHomeWorks = _presenter.filterHomeWorks(
                    //           _choosenClass, status, _homeworks);
                    //     }
                    //   });
                    // }
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget _buildHomeworkListMobile() {
    double height = 400;

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purpleSlight2,
            Color.fromARGB(0, 255, 255, 255),
            Color.fromARGB(0, 255, 255, 255)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DottedBorder(
          color: AppColors.purple,
          strokeWidth: 2,
          radius: const Radius.circular(50),
          dashPattern: const [8],
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                margin: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    _loading?.show(context);
                    _presenter.getListHomeWork();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded),
                      Text(
                        'Refresh Data',
                        style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                  child: Container(
                height: height,
                margin: const EdgeInsets.only(bottom: 10),
                // child: (_filterHomeWorks.isNotEmpty)
                //     ? ListView.builder(
                //         itemCount: _filterHomeWorks.length,
                //         padding: const EdgeInsets.symmetric(
                //             vertical: 10, horizontal: 10),
                //         itemBuilder: (BuildContext context, int index) {
                //           return _questionItemMobile(
                //               _filterHomeWorks.elementAt(index));
                //         })
                //     : NothingWidget.init().buildNothingWidget(
                //         'Nothing your homeworks in here',
                //         widthSize: 250,
                //         heightSize: 250),
              ))
            ],
          )),
    );
  }

  Widget _buildHomeworkListDesktop() {
    double height = 450;

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 100, right: 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purpleSlight2,
            Color.fromARGB(0, 255, 255, 255),
            Color.fromARGB(0, 255, 255, 255)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DottedBorder(
          color: AppColors.purple,
          strokeWidth: 2,
          radius: const Radius.circular(50),
          dashPattern: const [8],
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              InkWell(
                  onTap: () {
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
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                // child: (_filterHomeWorks.isNotEmpty)
                //     ? Center(
                //         child: GridView.count(
                //         crossAxisCount: 2,
                //         childAspectRatio: 7,
                //         crossAxisSpacing: 1,
                //         mainAxisSpacing: 1,
                //         children: _filterHomeWorks
                //             .map((data) => _questionItem(data))
                //             .toList(),
                //       ))
                //     : NothingWidget.init().buildNothingWidget(
                //         'Nothing your homeworks in here',
                //         widthSize: 250,
                //         heightSize: 250),
              ))
            ],
          )),
    );
  }

  Widget _questionItem(HomeWorkModel homeWork) {
    Map<String, dynamic> statusMap =
        Utils.instance().getHomeWorkStatus(homeWork) ?? {};
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
                    Text(Utils.instance().getPartOfTest(homeWork.testOption),
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
                      child: Text(homeWork.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black))),
                  Row(
                    children: [
                      Text(
                          (homeWork.end.isNotEmpty)
                              ? homeWork.end.toString()
                              : '0000-00-00 00:00',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black)),
                      const Text(' | ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text(
                          (statusMap.isNotEmpty)
                              ? '${statusMap['title']} ${Utils.instance().haveAiResponse(homeWork)}'
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: (statusMap.isNotEmpty)
                                ? statusMap['color']
                                : AppColors.purple,
                          ))
                    ],
                  )
                ],
              ),
            ],
          ),
          (homeWork.status == Status.OUT_OF_DATE.get ||
                  homeWork.status == Status.NOT_COMPLETED.get)
              ? SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        // _provider.setCurrentMainWidget(
                        //     DoingTest(homework: homeWork));
                        // print('HomeWork Id : ${homeWork.id}');
                      }
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

  Widget _questionItemMobile(HomeWorkModel homeWork) {
    Map<String, dynamic> statusMap =
        Utils.instance().getHomeWorkStatus(homeWork) ?? {};
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
                margin: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: AppColors.purple),
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Part",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w400,
                            fontSize: 8)),
                    // Text(_getPartOfTest(homeWork.testOption),
                    //     style: TextStyle(
                    //         color: AppColors.purple,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 14))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(homeWork.name.toString(),
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.black)),
                  ),
                  Row(
                    children: [
                      Text(
                          (statusMap.isNotEmpty)
                              ? '${statusMap['title']} ${Utils.instance().haveAiResponse(homeWork)}'
                              : '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: (statusMap.isNotEmpty)
                                ? statusMap['color']
                                : AppColors.purple,
                          )),
                      const Text('| ',
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                      Text(
                          (homeWork.end.isNotEmpty)
                              ? homeWork.end.toString()
                              : '0000-00-00 00:00',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black)),
                    ],
                  )
                ],
              ),
            ],
          ),
          (homeWork.status == Status.OUT_OF_DATE.get ||
                  homeWork.status == Status.NOT_COMPLETED.get)
              ? SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // if (context.mounted) {
                      //   _provider.setCurrentMainWidget(
                      //       DoingTest(homework: homeWork));
                      //   print('HomeWork Id : ${homeWork.id}');
                      // }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(AppColors.purple),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
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
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Details"),
                      )),
                )
        ],
      ),
    );
  }

  List<String> _getClassSelect(List<HomeWorkModel> homeworks) {
    List<String> classNames = [];

    for (HomeWorkModel homeWork in homeworks) {
      if (homeWork.className != null &&
          homeWork.className.toString().isNotEmpty) {
        classNames.add(homeWork.className.toString());
      }
    }
    classNames.insert(0, 'Alls');
    return LinkedHashSet<String>.from(classNames).toList();
  }

  @override
  void onGetListHomeworkComplete(
      List<HomeWorkModel> homeworks, List<ClassModel> classes) {
    print(
        'home work : ${homeworks.length.toString()}, classes: ${classes.length.toString()}');
    _loading?.hide();
  }

  @override
  void onGetListHomeworkError(String message) {
    print(
        'onGetListHomeworkError : $message');
    _loading?.hide();
  }

  @override
  void onLogoutComplete() {
    print(
        'onLogoutComplete');
    _loading?.hide();
  }

  @override
  void onLogoutError(String message) {
    print(
        'onLogoutError');
    _loading?.hide();
  }

  @override
  void onUpdateCurrentUserInfo(UserDataModel userDataModel) {
    print(
        'onUpdateCurrentUserInfo');
    _loading?.hide();
  }
}
