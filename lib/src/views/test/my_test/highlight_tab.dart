import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

class HighlightTab extends StatefulWidget {
  const HighlightTab({super.key});

  @override
  State<HighlightTab> createState() => _HighlightTabState();
}

class _HighlightTabState extends State<HighlightTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _buildListHighlightContainer(),
    );
  }

  Widget _buildListHighlightContainer() {
    return Container(
      height: Utils.instance().getDevicesHeight(context) * 0.8,
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 150,
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 20,
          ),
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return _buildHighlightItem(
              index: index + 1,
              title: 'Unit 1: Getting start - A closer look 1',
              user: 'Saitama',
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlightItem({
    required int index,
    required String title,
    required String user,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            style: BorderStyle.solid,
            color: Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  width: 90,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('lib/assets/ic_user_avatar.png'),
                        width: 60,
                      ),
                      Text(
                        user,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    height: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '16-05-2023 00:00',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  height: 100,
                  width: 50,
                  child: Stack(
                    children: [
                      Image(
                        image: AssetImage('lib/assets/ic_highlight.png'),
                        width: 40,
                        alignment: Alignment.topCenter,
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '8.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}