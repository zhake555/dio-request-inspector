import 'package:dio_request_inspector/src/model/http_activity.dart';

enum SortActivity { byTime, byMethod, byStatus }

void sortActivities(List<HttpActivity> activities, SortActivity sortType) {
  switch (sortType) {
    case SortActivity.byTime:
      activities.sort((a, b) => b.createdTime.compareTo(a.createdTime));
      break;
    case SortActivity.byMethod:
      activities.sort((a, b) => a.method.compareTo(b.method));
      break;
    case SortActivity.byStatus:
      activities.sort((a, b) =>
          a.response?.status?.compareTo(b.response?.status ?? 0) ?? 0);
      break;
  }
}
