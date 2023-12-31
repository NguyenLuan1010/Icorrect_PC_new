import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/core/app_colors.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../../models/simulator_test_models/question_topic_model.dart';
import '../../presenters/test_room_presenter.dart';
import '../../providers/re_answer_provider.dart';
import '../../utils/utils.dart';

// ignore: must_be_immutable
class ReAnswerDialog extends Dialog {
  final BuildContext _context;
  final QuestionTopicModel _question;
  Timer? _countDown;
  int _timeRecord = 30;
  late Record _record;
  final String _filePath = '';
  final String _currentTestId;
  final Function(QuestionTopicModel question) _finishReanswerCallback;

  ReAnswerDialog(this._context, this._question, this._currentTestId,
      this._finishReanswerCallback,
      {super.key});

  @override
  double? get elevation => 0;

  @override
  Color? get backgroundColor => Colors.white;
  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    _timeRecord = Utils.instance().getRecordTime(_question.numPart);

    _record = Record();
    _startCountDown();
    _startRecord();

    return Container(
      width: 400,
      height: 280,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your answers are being recorded',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Image(image: AssetImage(AppAssets.img_micro)),
            const SizedBox(height: 10),
            Consumer<ReAnswerProvider>(
              builder: (context, reAnswerProvider, child) {
                return Text(
                  reAnswerProvider.strCount,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    _cancelReAnswer();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.defaultGrayColor),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
                const SizedBox(width: 20),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    _finishReAnswer(_question);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      "Finish",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
                const SizedBox(width: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _finishReAnswer(QuestionTopicModel question) {
    _record.stop();
    _countDown!.cancel();
    _finishReanswerCallback(question);
    Navigator.pop(_context);
  }

  void _cancelReAnswer() {
    _record.stop();
    _countDown!.cancel();
    Navigator.pop(_context);
  }

  void _startCountDown() {
    Future.delayed(Duration.zero).then((value) {
      _countDown != null ? _countDown!.cancel() : '';
      _countDown = _countDownTimer(_context, _timeRecord, false);
      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("00:$_timeRecord");
    });
  }

  void _startRecord() async {
    String path =
        await Utils.instance().getAudioPathToPlay(_question, _currentTestId);

    if (await _record.hasPermission()) {
      await _record.start(
        path: path,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  Timer _countDownTimer(BuildContext context, int count, bool isPart2) {
    bool finishCountDown = false;
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      Provider.of<ReAnswerProvider>(_context, listen: false)
          .setCountDown("$minuteStr:$secondStr");

      if (count == 0 && !finishCountDown) {
        finishCountDown = true;
        _finishReAnswer(_question);
      }
    });
  }
}
