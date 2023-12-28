import 'package:flutter/material.dart';

import '../models/my_practice_test_model/my_practice_response_model.dart';
import '../models/my_practice_test_model/my_practice_test_model.dart';

class MyPracticeTestsProvider extends ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool loading) {
    _isLoading = loading;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _totalPage = 0;
  int get totalPage => _totalPage;
  void setTotalPage(int total) {
    _totalPage = total;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  int _currrentPage = 0;
  int get currentPage => _currrentPage;
  void setCurrentPage(int page) {
    _currrentPage = page;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  MyPracticeResponseModel _myPracticeResponseModel = MyPracticeResponseModel();
  MyPracticeResponseModel get myPracticeResponseModel =>
      _myPracticeResponseModel;
  void setMyPracticeResponseModel(MyPracticeResponseModel model) {
    _myPracticeResponseModel = model;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  List<MyPracticeTestModel> _myTestsList = [];
  List<MyPracticeTestModel> get myTestsList => _myTestsList;
  void setMyTestsList(List<MyPracticeTestModel> list) {
    if (_myTestsList.isNotEmpty) {
      _myTestsList.clear();
    }
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void removeTestAt(int indexDeleted) {
    _myTestsList.removeAt(indexDeleted);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void addMyTestsList(List<MyPracticeTestModel> list) {
    _myTestsList.addAll(list);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearMyTestsList() {
    _myTestsList.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
