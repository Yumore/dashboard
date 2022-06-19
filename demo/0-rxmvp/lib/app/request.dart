import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class Request {
  static const String baseUrl = 'http://www.shuqi.com/';

  static Future<dynamic> get({required String action, Map? params}) async {
    return Request.mock(action: action, params: params);
  }

  static Future<dynamic> post({required String action, Map? params}) async {
    return Request.mock(action: action, params: params);
  }

  static Future<dynamic> mock({required String action, Map? params}) async {
    var responseStr = await rootBundle.loadString('mock/$action.json');
    var responseJson = json.decode(responseStr);
    return responseJson['data'];
  }
}
