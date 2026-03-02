import 'dart:io' show Cookie;
import 'form_data.dart';

class HttpRequest {
  int size = 0;
  DateTime time = DateTime.now();
  String? headers;
  String? body;
  String? contentType;
  List<Cookie> cookies = [];
  Map<String, dynamic> queryParameters = <String, dynamic>{};
  List<FormDataFile>? formDataFiles;
  List<FormDataField>? formDataFields;
}
