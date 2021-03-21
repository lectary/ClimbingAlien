import 'dart:convert';
import 'dart:io';

import 'package:climbing_alien/model/climbr_data.dart';
import 'package:climbing_alien/utils/exceptions/internet_exception.dart';
import 'package:climbing_alien/utils/exceptions/server_response_exception.dart';
import 'package:http/http.dart' as http;

class ClimbrApi {
  static const String _uri_authority = "ro.ogg.at";
  static const String _uri_path = "/ClimbingAlien/w/w.php";

  fetchWalls() async {
    http.Response response;
    try {
      response = await http.get(Uri.https(_uri_authority, _uri_path));
    } on SocketException {
      throw InternetException("Please check your internet connection!");
    }

    if (response.statusCode == 200) {
      return ClimbrData.fromJson(json.decode(response.body));
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }
}
