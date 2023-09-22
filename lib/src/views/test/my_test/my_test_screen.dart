import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:icorrect_pc/src/providers/my_test_provider.dart';
import 'package:icorrect_pc/src/utils/utils.dart';
import 'package:icorrect_pc/src/views/test/my_test/my_test_detail_tab.dart';
import 'package:icorrect_pc/src/views/test/my_test/response_tab.dart';
import 'package:provider/provider.dart';

import 'highlight_tab.dart';
import 'others_tab.dart';

class MyTestScreen extends StatefulWidget {
  const MyTestScreen({super.key});

  @override
  State<StatefulWidget> createState() => MyTestScreenState();
}

class MyTestScreenState extends State<MyTestScreen> {
  String focusTab = 'My test';
  Widget curScreen = const MyTestTab();
  late MyTestProvider _provider;

  @override
  void initState() {
    _provider = Provider.of<MyTestProvider>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utils.instance().getDevicesWidth(context) * 0.05,
          vertical: Utils.instance().getDevicesHeight(context) * 0.03,
        ),
        child: Expanded(
          child: Consumer<MyTestProvider>(
            builder: (context, provider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumb(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildTabButton(title: 'My test'),
                        _buildTabButton(title: 'Response'),
                        _buildTabButton(title: 'Highlight'),
                        _buildTabButton(title: 'Others'),
                      ],
                    ),
                  ),
                  _provider.curTab,
                  // context.watch<MyProvider>().curTab
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _getCurrentScreen() {
    switch (focusTab) {
      case 'My Test':
        curScreen = const MyTestTab();
        break;
      case 'Response':
        curScreen = const ResponseTab();
        break;
      case 'Highlight':
        curScreen = const HighlightTab();
        break;
      case 'Others':
        curScreen = const OthersTab();
        break;
      default:
        curScreen = const MyTestTab();
    }
  }

  Widget _buildTabButton({required String title}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          focusTab = title;
          _getCurrentScreen();
          _provider.curTab = curScreen;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
          child: Container(
            color: focusTab == title ? Colors.grey : Colors.transparent,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
              top: 2,
              left: 2,
              right: 2,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(13),
                topLeft: Radius.circular(13),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BreadCrumb.builder(
          overflow: const WrapOverflow(
            keepLastDivider: false,
          ),
          divider: const Icon(Icons.chevron_right),
          itemCount: 5,
          builder: (int index) {
            return BreadCrumbItem(
              onTap: () {},
              content: const Text(
                'Item 1',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}