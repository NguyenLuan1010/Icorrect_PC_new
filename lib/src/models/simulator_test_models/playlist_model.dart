import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';

class PlayListModel {
  String? _fileIntro;
  String? _fileQuestionNormal;
  String? _fileQuestionSlow;
  String? _questionContent;
  String? _cueCard;
  String? _endOfTakeNote;
  String? _endOfTest;
  int? _numPart;
  bool? _isFollowUp;
  int? _questionLength;

  QuestionTopicModel? _questionTopicModel;

  get questionLength => _questionLength ?? 0;

  set questionLength(value) => _questionLength = value;

  bool get isFollowUp => _isFollowUp ?? false;

  set isFollowUp(bool value) => _isFollowUp = value;

  String get fileQuestionNormal => _fileQuestionNormal ?? "";

  set fileQuestionNormal(String value) => _fileQuestionNormal = value;

  get fileQuestionSlow => _fileQuestionSlow ?? "";

  set fileQuestionSlow(value) => _fileQuestionSlow = value;

  String get fileIntro => _fileIntro ?? "";

  set fileIntro(String? value) => _fileIntro = value;

  String get questionContent => _questionContent ?? "";

  set questionContent(value) => _questionContent = value;

  String get cueCard => _cueCard ?? "";

  set cueCard(String value) => _cueCard = value;

  String get endOfTakeNote => _endOfTakeNote ?? "";

  set endOfTakeNote(value) => _endOfTakeNote = value;

  String get endOfTest => _endOfTest ?? "";

  set endOfTest(value) => _endOfTest = value;

  int get numPart => _numPart ?? 0;

  set numPart(value) => _numPart = value;

  QuestionTopicModel get questionTopicModel =>
      _questionTopicModel ?? QuestionTopicModel();

  set questionTopicModel(value) => _questionTopicModel = value;
}
