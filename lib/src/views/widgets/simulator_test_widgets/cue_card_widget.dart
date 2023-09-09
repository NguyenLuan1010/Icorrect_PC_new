import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/providers/test_room_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/simulator_test_provider.dart';

class CueCardWidget extends StatefulWidget {
  const CueCardWidget({super.key});

  @override
  State<CueCardWidget> createState() => _CueCardWidgetState();
}

class _CueCardWidgetState extends State<CueCardWidget> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height / 2.5;

    return Consumer<TestRoomProvider>(
      builder: (context, provider, child) {
        if (provider.isVisibleCueCard &&
            provider.currentQuestion.cueCard.isNotEmpty) {
          return Container(
            width: w,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Cue Card",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      provider.strCountCueCard,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    provider.currentQuestion.content,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        provider.currentQuestion.cueCard.trim(),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
