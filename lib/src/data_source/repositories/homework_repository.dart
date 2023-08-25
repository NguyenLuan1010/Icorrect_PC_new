import 'package:flutter/foundation.dart';

import '../../utils/define_object.dart';
import '../api_urls.dart';
import 'app_repository.dart';
import 'package:http/http.dart' as http;

abstract class HomeWorkRepository {
  Future<String> getHomeWorks(String email);

}

class HomeWorkRepositoryImpl implements HomeWorkRepository {
  @override
  Future<String> getHomeWorks(String email) async {
    String url =
        '$API_DOMAIN$getHomeWorksEP?email=$email&status=${Status.LATE.get}';

    return AppRepository.init()
        .sendRequest(RequestMethod.GET, url, true)
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      final int statusCode = response.statusCode;

      if (statusCode != 200 || jsonBody.isNotEmpty) {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
      }
      return jsonBody;
    });
  }
}
