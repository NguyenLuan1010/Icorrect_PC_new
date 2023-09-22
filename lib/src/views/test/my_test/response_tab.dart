import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

class ResponseTab extends StatefulWidget {
  const ResponseTab({super.key});

  @override
  State<ResponseTab> createState() => _ResponseTabState();
}

class _ResponseTabState extends State<ResponseTab> {
  Set<String> ques = {
    'Can you please tell me your full name?',
    'Do you often eat with your family?',
    'Do you like cooking?',
    'What is your favorite food?',
    'What is your favorite drink?',
  };

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
      child: Column(
        children: [
          Container(child: Center(child: Text('Response'))),
        ],
      ),
    );
  }

  Widget _buildVideoQuesContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      width: Utils.instance().getDevicesWidth(context),
      height: Utils.instance().getDevicesHeight(context) * 0.4,
      child: const GridPaper(
        color: Colors.grey,
        divisions: 1,
        interval: 200,
        subdivisions: 10,
      ),
    );
  }

  Widget _buildListQuesContainer() {
    return Container(
      height: Utils.instance().getDevicesHeight(context) * 0.4,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 95,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: ques.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildQuesItem(
              index: index + 1,
              ques: ques.elementAt(index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuesItem({required int index, required String ques}) {
    return Container(
      width: 200,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        '$index. $ques',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            '00:00 | 9 repeats',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Re-answer',
                              style: TextStyle(
                                color: Color(0xFF50973B),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View Tips',
                              style: TextStyle(
                                color: Color(0xFFF2B549),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: Image(
                  image: AssetImage('lib/assets/ic_play.png'),
                  alignment: Alignment.center,
                  height: 50,
                ),
              ),
            ],
          ),
          const Divider(height: 1,color: Colors.grey,),
        ],
      ),
    );
  }

}
