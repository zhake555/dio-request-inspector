class HttpResponse {
  int? status = 0;
  int size = 0;
  DateTime time = DateTime.now();
  String? body;
  Map<String, List<String>>? headers;
}
