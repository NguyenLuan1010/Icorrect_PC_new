import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';

class TipQuestionDialog extends Dialog {
  BuildContext _context;
  QuestionTopicModel _questionTopicModel;

  TipQuestionDialog(this._context, this._questionTopicModel, {super.key});

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
    double w = MediaQuery.of(_context).size.width;
    double h = MediaQuery.of(_context).size.height;
    return Wrap(
      children: [
        Container(
          width: w / 2,
          padding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(_context).pop();
                  },
                  child: const Icon(Icons.cancel_outlined, size: 30),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tip",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _questionTopicModel.content,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.black,
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: h / 3,
                    child: SingleChildScrollView(
                      child: Text(
                        _questionTopicModel.tips,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
