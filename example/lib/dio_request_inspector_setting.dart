import 'package:dio_request_inspector/dio_request_inspector.dart';

final DioRequestInspector inspector = DioRequestInspector(
  isInspectorEnabled: true,
  showSummary: false,
);

final void Function() toInspector = inspector.goToInspector;
