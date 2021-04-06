import 'dart:convert';
import 'dart:io';

import 'package:climbing_alien/data/entity/wall.dart';
import 'package:climbing_alien/model/climbr_data.dart';
import 'package:climbing_alien/utils/exceptions/internet_exception.dart';
import 'package:climbing_alien/utils/exceptions/server_response_exception.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ClimbrApi {
  static const String urlApiEndpoint = "https://ro.ogg.at/ClimbingAlien/w/";

  static const String _uriAuthority = "ro.ogg.at";
  static const String _uriApiOverview = "/ClimbingAlien/w/w2.php";
  static const String _uriApiEndpoint = "/ClimbingAlien/w/";

  Future<List<Wall>> fetchWalls() async {
    http.Response response;
    try {
      response = await http.get(Uri.https(_uriAuthority, _uriApiOverview));
    } on SocketException {
      throw InternetException("Please check your internet connection!");
    }

    if (response.statusCode == 200) {
      return ClimbrData.fromJson(json.decode(response.body)).walls;
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  /// Downloads the passed file [fileName].
  /// Returns a [File] as [Future].
  /// Throws [InternetException] if there is no internet connection
  /// and [ServerResponseException] on any other errors or if the file could
  /// not be found, with corresponding error messages.
  Future<File> downloadFile(String fileName) async {
    String dirPath = (await getTemporaryDirectory()).path;

    http.Response response;
    try {
      response = await http.get(Uri.https(_uriAuthority, _uriApiEndpoint + fileName));
    } on SocketException {
      throw InternetException("No internet! Check your connection!");
    }
    if (response.statusCode == 200) {
      File file = File('$dirPath/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else if (response.statusCode == 404) {
      throw ServerResponseException("File: $fileName not found!");
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }

  /// Downloads the passed file [fileName].
  /// Returns a [http.StreamedResponse].
  /// Throws [InternetException] in case of connection errors
  /// and [ServerResponseException] on any other errors or if the file could
  /// not be found, with corresponding error messages.
  Future<http.StreamedResponse> downloadFileAsStream(String fileName) async {
    http.Client httpClient = http.Client();
    http.Request request = http.Request('GET', Uri.https(_uriAuthority, _uriApiEndpoint + fileName));

    http.StreamedResponse response;
    try {
      response = await httpClient.send(request);
    } on SocketException {
      throw InternetException("No internet! Check your connection!");
    }
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 404) {
      throw ServerResponseException("File: $fileName not found!");
    } else {
      throw ServerResponseException(
          "Error occurred while communicating with server with status code: ${response.statusCode.toString()}");
    }
  }
}
