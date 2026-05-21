import 'package:flutter_test/flutter_test.dart';
import 'package:dio_request_inspector/src/common/copy.dart';
import 'package:dio_request_inspector/src/model/http_activity.dart';
import 'package:dio_request_inspector/src/model/http_request.dart';
import 'package:dio_request_inspector/src/model/http_response.dart';

void main() {
  test('Copy.getListActivity returns formatted activities string', () {
    final activity1 = HttpActivity(1)
      ..method = 'GET'
      ..server = 'example.com'
      ..endpoint = '/api/v1/users'
      ..secure = true
      ..duration = 150
      ..request = (HttpRequest()
        ..size = 100
        ..headers = '{"content-type": "application/json"}')
      ..response = (HttpResponse()
        ..status = 200
        ..size = 200
        ..body = '{"success": true}');

    final activity2 = HttpActivity(2)
      ..method = 'POST'
      ..server = 'example.com'
      ..endpoint = '/api/v1/users'
      ..secure = true
      ..duration = 250
      ..request = (HttpRequest()
        ..size = 150
        ..headers = '{"content-type": "application/json"}'
        ..body = '{"name": "John"}')
      ..response = (HttpResponse()
        ..status = 201
        ..size = 50
        ..body = '{"id": 1}');

    final result = Copy.getListActivity([activity1, activity2]);

    expect(result, contains('Method: GET'));
    expect(result, contains('Server: example.com'));
    expect(result, contains('Endpoint: /api/v1/users'));
    expect(result, contains('========================================'));
    expect(result, contains('Method: POST'));
  });
}
