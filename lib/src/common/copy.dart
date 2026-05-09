import 'dart:io';
import 'package:dio_request_inspector/src/common/copy_settings_storage.dart';
import 'package:dio_request_inspector/src/common/extensions.dart';
import 'package:dio_request_inspector/src/common/helpers.dart';
import 'package:dio_request_inspector/src/model/http_activity.dart';

class Copy {
  static String getCurlCommand(HttpActivity call) {
    bool compressed = false;
    final StringBuffer curlCmd = StringBuffer('curl');

    curlCmd.write(' -X ${call.method}');

    final settings = CopySettingsStorage.current;
    final allHeaders = Helper.decodeRawJson(call.request?.headers ?? '{}');
    final headers = Map<String, dynamic>.from(allHeaders)
      ..removeWhere(
          (key, _) => settings.excludedHeaders.contains(key.toLowerCase()));

    for (final MapEntry<String, dynamic> header in headers.entries) {
      final headerValue = header.value?.toString() ?? '';
      if (headerValue.isNotEmpty) {
        if (header.key.toLowerCase() == HttpHeaders.acceptEncodingHeader &&
            headerValue.toLowerCase() == 'gzip') {
          compressed = true;
        }

        curlCmd.write(' -H "${header.key}: $headerValue"');
      }
    }

    final String? requestBody = call.request?.body?.toString();
    if (requestBody != null &&
        requestBody.isNotEmpty &&
        requestBody != 'null') {
      final escapedBody = requestBody.replaceAll("'", "'\\''");
      curlCmd.write(" --data '$escapedBody'");
    }

    final Map<String, dynamic>? queryParamMap = call.request?.queryParameters;
    final StringBuffer queryParams = StringBuffer();

    if (queryParamMap != null && queryParamMap.isNotEmpty) {
      final parts = <String>[];
      for (final entry in queryParamMap.entries) {
        if (entry.value is List) {
          for (final val in entry.value as List) {
            parts.add('${entry.key}=$val');
          }
        } else {
          parts.add('${entry.key}=${entry.value}');
        }
      }
      queryParams.write('?');
      queryParams.write(parts.join('&'));
    }

    if (call.server.contains('http://') || call.server.contains('https://')) {
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${call.server}${call.endpoint}$queryParams'"}",
      );
    } else {
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${call.secure ? 'https://' : 'http://'}${call.server}${call.endpoint}$queryParams'"}",
      );
    }

    return curlCmd.toString();
  }

  static String getActivity(HttpActivity data) {
    var contentTypeList = data.response?.headers?["content-type"];
    final isImage = contentTypeList != null &&
        contentTypeList.any((element) => element.contains('image'));

    final settings = CopySettingsStorage.current;
    final StringBuffer activityDetails = StringBuffer();

    activityDetails.writeln('\n--- HTTP Activity ---');
    activityDetails.writeln('Method: ${data.method}');
    activityDetails.writeln('Server: ${data.server}');
    activityDetails.writeln('Endpoint: ${data.endpoint}');
    activityDetails.writeln('Secure: ${data.secure}');
    activityDetails.writeln('Time: ${data.request?.time}');
    activityDetails.writeln('Started: ${data.response?.time}');
    activityDetails.writeln('Duration: ${Helper.formatTime(data.duration)}');
    activityDetails
        .writeln('Bytes Sent: ${Helper.formatBytes(data.request?.size ?? 0)}');
    activityDetails.writeln(
        'Bytes Received: ${Helper.formatBytes(data.response?.size ?? 0)}');

    activityDetails.writeln('\n--- Request ---');

    if (settings.copyRequestHeaders) {
      final requestHeaders =
          Helper.decodeRawJson(data.request?.headers ?? '{}')
            ..removeWhere(
                (key, _) => settings.excludedHeaders.contains(key.toLowerCase()));
      final headersEncoded = Helper.encodeRawJson(requestHeaders);
      if (headersEncoded != null && headersEncoded.isNotEmpty) {
        activityDetails.writeln('Headers: ${headersEncoded.prettify}');
      }
    }

    final queryEncoded = Helper.encodeRawJson(data.request?.queryParameters);
    if (queryEncoded != null && queryEncoded.isNotEmpty) {
      activityDetails.writeln('Query Parameters: ${queryEncoded.prettify}');
    }

    final requestBody = data.request?.body;
    if (requestBody != null && requestBody.isNotEmpty) {
      activityDetails.writeln('Body: ${requestBody.prettify}');
    }

    activityDetails.writeln('\n--- Response ---');
    activityDetails.writeln('Status Code: ${data.response?.status}');

    if (settings.copyResponseHeaders) {
      final responseHeaders = Helper.encodeRawJson(data.response?.headers);
      if (responseHeaders != null && responseHeaders.isNotEmpty) {
        activityDetails.writeln('Headers: $responseHeaders');
      }
    }

    final responseBody = isImage ? 'Image Body' : data.response?.body;
    if (responseBody != null && responseBody.isNotEmpty) {
      activityDetails.writeln('Body: ${responseBody.prettify}');
    }

    return activityDetails.toString();
  }
}
