import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../utils/utils.dart';
import '../api_urls.dart';

class AppRepository {
  AppRepository._();
  static final AppRepository _repositories = AppRepository._();
  factory AppRepository.init() => _repositories;

  Future<http.Response> sendRequest(method, String url, bool hasToken,
      {Object? body, Encoding? encoding}) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (hasToken == true) {
      String token = await Utils.instance().getAccessToken() ?? '';
      headers['Authorization'] = 'Bearer $token';
    }

    if (method == RequestMethod.GET) {
      return http.get(Uri.parse(url), headers: headers);
    }

    if (method == RequestMethod.POST) {
      return http.post(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == RequestMethod.PUT) {
      return http.put(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }
    if (method == RequestMethod.PATCH) {
      return http.patch(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == RequestMethod.DELETE) {
      return http.delete(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    return http.get(Uri.parse(url), headers: headers);
  }

  Future<http.StreamedResponse> pushFileWAV(
      String url, Map<String, String> formData, List<File> files) async {
    var request = http.MultipartRequest(RequestMethod.POST, Uri.parse(url));

    String accessToken = await Utils.instance().getAccessToken() ?? '';
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken'
    });

    for (File file in files) {
      File audioFile = File('${file.path}.wav');
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFile.path));
    }
    request.fields.addAll(formData);

    return await request.send();
  }
}
