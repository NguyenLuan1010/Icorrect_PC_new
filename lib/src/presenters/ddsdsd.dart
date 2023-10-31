// import 'package:icorrect_pc/src/data_source/constants.dart';
// import 'package:icorrect_pc/src/models/simulator_test_models/playlist_model.dart';
// import 'package:icorrect_pc/src/models/simulator_test_models/question_topic_model.dart';
// import 'package:icorrect_pc/src/models/simulator_test_models/test_detail_model.dart';
// import 'package:icorrect_pc/src/models/simulator_test_models/topic_model.dart';

// List<PlayListModel> gcetPlayList(TestDetailModel testDetailModel) {
//     List<PlayListModel> playList = [];
//     List<TopicModel> topicsList = getListTopicModel(testDetailModel);

//     for (int i = 0; i < topicsList.length; i++) {
//       TopicModel topic = topicsList.elementAt(i);

//       List<QuestionTopicModel> questions = getAllQuestionsTopic(topic);

//       if (topic.files.isNotEmpty && topic.questionList.isNotEmpty) {
//         PlayListModel playListIntro = PlayListModel();
//         playListIntro.questionContent = PlayListType.introduce.name;
//         playListIntro.numPart = topic.numPart;
//         playListIntro.fileIntro =
//             topic.files.isNotEmpty ? topic.files.first.url : "";
//         playList.add(playListIntro);
//       }

//       for (int j = 0; j < questions.length; j++) {
//         print('topic numpart : ${topic.numPart.toString()}');
//         PlayListModel playListModel = PlayListModel();
//         playListModel.numPart = topic.numPart;
//         playListModel.endOfTakeNote = topic.endOfTakeNote.url;
//         playListModel.endOfTest = topic.fileEndOfTest.url;
//         QuestionTopicModel question = questions.elementAt(j);
//         question.numPart = topic.numPart;
//         playListModel.questionContent = question.content;
//         playListModel.cueCard = question.cueCard;
//         playListModel.isFollowUp = question.isFollowUpQuestion();
//         List<FileTopicModel> files = question.files;
//         playListModel.questionTopicModel = question;
//         playListModel.fileQuestionNormal = files.first.url;
//         playListModel.fileQuestionSlow = files.length > 1
//             ? files.last.url
//             : playListModel.fileQuestionNormal;
//         List<FileTopicModel> filesImage = _getFilesImage(files);
//         playListModel.fileImage =
//             filesImage.isNotEmpty ? filesImage.first.url : '';
//         playList.add(playListModel);
//       }

//       if (topic.endOfTakeNote.url.isNotEmpty && topic.questionList.isNotEmpty) {
//         PlayListModel playListEndOfTakeNote = PlayListModel();
//         playListEndOfTakeNote.endOfTakeNote = topic.endOfTakeNote.url;
//         playListEndOfTakeNote.questionContent = PlayListType.endOfTakeNote.name;
//         playListEndOfTakeNote.numPart = 2;
//         playList.add(playListEndOfTakeNote);
//       }

//       if (topic.fileEndOfTest.url.isNotEmpty) {
//         PlayListModel playListEndOfTest = PlayListModel();
//         playListEndOfTest.endOfTest = topic.fileEndOfTest.url;
//         playListEndOfTest.questionContent = PlayListType.endOfTest.name;
//         playListEndOfTest.numPart = 3;
//         playList.add(playListEndOfTest);
//       }
//     }

//     playList.sort((a, b) => a.numPart.compareTo(b.numPart));

//     return playList;
//   }