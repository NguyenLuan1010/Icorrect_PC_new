import 'package:flutter/foundation.dart';

import '../api_urls.dart';
import 'app_repository.dart';
import 'package:http/http.dart' as http;

abstract class HomeWorkRepository {
  Future<String> getHomeWorks(String email,String status);

}

class HomeWorkRepositoryImpl implements HomeWorkRepository {
  @override
  Future<String> getHomeWorks(String email,String status) async {

     Map<String, String> queryParameters = {'email': email, 'status': status};
    String url = getActivitiesList(queryParameters);
            
    if (kDebugMode) {
      print('DEBUG: HomeWorkRepositoryImpl - url :$url');
    }
    return AppRepository.init()
        .sendRequest(
          RequestMethod.get,
          url,
          true,
        )
        .timeout(const Duration(seconds: 20))
        .then((http.Response response) {
      return response.body;
    });
  }
}
