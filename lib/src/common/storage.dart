import 'dart:collection';

import 'package:dio_request_inspector/src/model/http_activity.dart';
import 'package:dio_request_inspector/src/model/http_error.dart';
import 'package:dio_request_inspector/src/model/http_response.dart';
import 'package:flutter/foundation.dart';

class HttpActivityStorage {
  static const int maxActivities = 500;

  final LinkedHashMap<int, HttpActivity> _activityMap =
      LinkedHashMap<int, HttpActivity>();

  final ValueNotifier<List<HttpActivity>> _activities =
      ValueNotifier<List<HttpActivity>>([]);

  ValueNotifier<List<HttpActivity>> get activitiesNotifier => _activities;

  void addActivity(HttpActivity activity) {
    _activityMap[activity.id] = activity;
    if (_activityMap.length > maxActivities) {
      _activityMap.remove(_activityMap.keys.first);
    }
    _emitUpdate();
  }

  void addResponse(HttpResponse response, int hashCode) {
    final HttpActivity? selectedCall = whereId(hashCode);

    if (selectedCall == null) {
      return;
    }

    selectedCall
      ..loading = false
      ..response = response
      ..duration = response.time.millisecondsSinceEpoch -
          (selectedCall.request?.time.millisecondsSinceEpoch ?? 0);

    _emitUpdate();
  }

  HttpActivity? whereId(int hashCode) {
    return _activityMap[hashCode];
  }

  void addError(HttpError error, int hashCode) {
    final HttpActivity? activity = whereId(hashCode);

    if (activity == null) {
      return;
    }

    activity.error = error;
    activity.loading = false;
    _emitUpdate();
  }

  void clear() {
    _activityMap.clear();
    _emitUpdate();
  }

  void _emitUpdate() {
    _activities.value = _activityMap.values.toList();
  }
}
