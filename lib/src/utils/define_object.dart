enum SizeScreen {
  MINIMUM_WiDTH_1(1200),
  MINIMUM_WiDTH_2(900);

  const SizeScreen(this.size);
  final double size;
}

enum ToastStatesType {
  success,
  error,
  warning,
}

enum AuthType {
  login,
  register,
  get_user_infor,
}

enum PasswordType {
  password,
  confirm_password,
  current_password,
  new_password,
  confirm_new_password,
}

enum Status {
  CORRECTED(2),
  LATE(-1),
  OUT_OF_DATE(-2),
  SUBMITTED(1),
  NOT_COMPLETED(0),
  TRUE(1),
  FALSE(0),
  HIGHTLIGHT(1),
  OTHERS(0),
  HAD_SCORE(1),
  ALL_HOMEWORK(-1);

  const Status(this.get);

  final int get;
}

enum PartOfTest {
  INTRODUCE(0),
  PART1(1),
  PART2(2),
  PART3(3),
  FOLLOW_UP(4),
  END_OF_TEST(5);

  const PartOfTest(this.get);
  final int get;
}

enum Question {
  FILE_INTRO(0),
  INTRODUCE(1),
  PART1(2),
  PART2(3),
  PART3(4),
  FOLLOW_UP(5),
  END_OF_QUESTION(6);

  const Question(this.part);
  final int part;
}

enum Alert {
  NETWORK_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_no_internet.png'
  }),

  SERVER_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Contact with us',
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  WARNING({
    Alert.cancelTitle: 'Cancel',
    Alert.actionTitle: 'Out the test',
    Alert.icon: 'assets/images/img_warning.png'
  }),

  DOWNLOAD_ERROR({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_server_error.png'
  }),

  DATA_NOT_FOUND({
    Alert.cancelTitle: 'Exit',
    Alert.actionTitle: 'Try again',
    Alert.icon: 'assets/images/img_not_found.png'
  });

  const Alert(this.type);
  static const cancelTitle = 'cancel_title';
  static const actionTitle = 'action_title';
  static const icon = 'icon';
  final Map<String, String> type;
}

enum SelectType { classType, statusType }

class FilterJsonData {
  static Map<String, dynamic> selectAll = {"id": -111, "name": "SelectAll"};
  static Map<String, dynamic> submitted = {"id": 1, "name": "Submitted"};
  static Map<String, dynamic> corrected = {"id": 2, "name": "Corrected"};
  static Map<String, dynamic> notCompleted = {"id": 0, "name": "Not Completed"};
  static Map<String, dynamic> late = {"id": -1, "name": "Late"};
  static Map<String, dynamic> outOfDate = {"id": -2, "name": "Out of date"};
}