import 'package:dio_request_inspector/src/model/http_activity.dart';
import 'package:dio_request_inspector/src/model/http_error.dart';
import 'package:dio_request_inspector/src/model/http_response.dart';
import 'package:rxdart/rxdart.dart';

class HttpActivityStorage {
  static const int maxActivities = 500;

  final BehaviorSubject<List<HttpActivity>> _activities =
      BehaviorSubject.seeded([]);

  Stream<List<HttpActivity>> get activities => _activities.stream;

  void addActivity(HttpActivity activity) {
    final list = [..._activities.value, activity];
    if (list.length > maxActivities) {
      list.removeRange(0, list.length - maxActivities);
    }
    _activities.add(list);
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

    _activities.add([..._activities.value]);
  }

  HttpActivity? whereId(int hashCode) {
    return _activities.value
        .where((element) => element.id == hashCode)
        .firstOrNull;
  }

  void addError(HttpError error, int hashCode) {
    final HttpActivity? activity = whereId(hashCode);

    if (activity == null) {
      return;
    }

    activity.error = error;
    activity.loading = false;
    _activities.add([..._activities.value]);
  }

  void clear() {
    _activities.add([]);
  }
}
