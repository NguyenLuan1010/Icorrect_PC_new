import 'package:flutter/material.dart';

class MyGridView extends StatelessWidget {
  List<dynamic> data;
  Widget Function(dynamic itemModel, int index) itemWidget;
  MyGridView({super.key, required this.data, required this.itemWidget});

  @override
  Widget build(BuildContext context) {
    return _createGridView();
  }

  Widget _createGridView() {
    List<dynamic> list1 = [];
    List<dynamic> list2 = [];
    for (int i = 0; i < data.length; i++) {
      if (i % 2 != 0) {
        list2.add(data[i]);
      } else {
        list1.add(data[i]);
      }
    }
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: list1.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return itemWidget(list1[i], i);
                  })),
          Expanded(
              child: ListView.builder(
                  itemCount: list2.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return itemWidget(list2[i], i + list1.length);
                  })),
        ],
      ),
    );
  }
}
