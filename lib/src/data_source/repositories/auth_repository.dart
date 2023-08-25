import 'package:flutter/foundation.dart';

import '../api_urls.dart';
import 'package:http/http.dart' as http;
import 'app_repository.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> logout();
  Future<String> getUserInfo(String deviceId, String appVersion, String os);
  Future<String> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    String url = '$API_DOMAIN$loginEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.POST,
          url,
          false,
          body: <String, String>{'email': email, 'password': password},
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
          final String jsonBody = response.body;
          final int statusCode = response.statusCode;

          if (statusCode != 200 || jsonBody == null) {
            if (kDebugMode) {
              print(response.reasonPhrase);
            }
            // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
          }
          return jsonBody;
        });
  }

  @override
  Future<String> getUserInfo(String deviceId, String appVersion, String os) {
    String url = '$API_DOMAIN$getUserInforEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.POST,
          url,
          true,
          body: <String, String>{
            'device_id': deviceId,
            'app_version': appVersion,
            'os': os
          },
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
          final String jsonBody = response.body;
          final int statusCode = response.statusCode;

          if (statusCode != 200 || jsonBody == null) {
            if (kDebugMode) {
              print(response.reasonPhrase);
            }
            // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
          }
          return jsonBody;
        });
  }

  @override
  Future<String> logout() {
    String url = '$API_DOMAIN$logoutEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.POST,
          url,
          true,
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
      final String jsonBody = response.body;
      final int statusCode = response.statusCode;

      if (statusCode != 200 || jsonBody == null) {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
        // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
      }
      return jsonBody;
    });
  }

  @override
  Future<String> changePassword(
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) {
    String url = '$API_DOMAIN$changePasswordEP';

    return AppRepository.init()
        .sendRequest(
          RequestMethod.POST,
          url,
          true,
          body: <String, String>{
            'password_old': oldPassword,
            'password': newPassword,
            'password_confirmation': confirmNewPassword,
          },
        )
        .timeout(const Duration(seconds: 15))
        .then((http.Response response) {
          final String jsonBody = response.body;
          final int statusCode = response.statusCode;

          if (statusCode != 200 || jsonBody == null) {
            if (kDebugMode) {
              print(response.reasonPhrase);
            }
            // throw FetchDataException("StatusCode:$statusCode, Error:${response.reasonPhrase}");
          }
          return jsonBody;
        });
  }
}
