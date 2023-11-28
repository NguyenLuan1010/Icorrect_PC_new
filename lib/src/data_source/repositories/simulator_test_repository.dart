// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import '../api_urls.dart';
import 'app_repository.dart';

abstract class SimulatorTestRepository {
  Future<String> getTestDetail(String homeworkId, String distributeCode);
  Future<String> submitTest(http.MultipartRequest multiRequest);
}

class SimulatorTestRepositoryImpl implements SimulatorTestRepository {
  final int timeOutForSubmit = 60;
  @override
  Future<String> getTestDetail(String homeworkId, String distributeCode) {
    String url = '$apiDomain$getTestInfoEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.post,
          url,
          true,
          body: <String, String>{
            'activity_id': homeworkId,
            'distribute_code': distributeCode,
            'platform': "pc_flutter_for_exam",
            'app_version': '1.1.0',
            'device_id': '22344663212',
          },
        )
        .timeout(Duration(seconds: timeOutForSubmit))
        .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
  }

  @override
  Future<String> submitTest(http.MultipartRequest multiRequest) async {
    return await multiRequest
        .send()
        .timeout(Duration(seconds: timeOutForSubmit))
        .then((http.StreamedResponse streamResponse) async {
      if (streamResponse.statusCode == 200) {
        return await http.Response.fromStream(streamResponse)
            .timeout(Duration(seconds: timeOutForSubmit))
            .then((http.Response response) {
          final String jsonBody = response.body;
          return jsonBody;
        });
      } else {
        return '';
      }
    });
  }
}
