<p align="center">
    <img src="https://user-images.githubusercontent.com/91040581/210127198-791f085b-61b8-4a77-8168-986c9a90d806.png" width="200" height="185">
</p>

<h3 align="center">Dio Requests Inspector</h3>

<p align="center">
A HTTP inspector for Dio, which can intercept and log HTTP requests and responses.
  <br>
  <br>
  <br>
  <br>
</p>

![ss](https://github.com/bayunugroho2022/dio-request-inspector/assets/91040581/efd6d3c9-c068-4fed-a94e-a30b9cd616ab)
<br>

## Features

- [X] Intercept and log HTTP requests and responses
- [X] Secure HTTP requests with passwords
- [X] Filter logs by request time, method, and status
- [X] Search logs by path
- [X] Easily share request and response data
- [X] Beautify JSON data
- [X] Beautiful user interface

## How to use

- Add the package with command

```bash
flutter pub add dio_request_inspector
```

- add `navigatorObservers` to your `MaterialApp`

```dart
navigatorObservers: [
  DioRequestInspector.navigatorObserver,
],
```

- Wrap your `myApp` with `DioRequestInspectorMain`

```dart
void main() {
  runApp(DioRequestInspectorMain(
    isDebugMode: true,
    child: MyApp(),
  ));
}
```

- add interceptor to your Dio instance

```dart
final DioRequestInspector inspector = DioRequestInspector(
  isInspectorEnabled: true,
  password: '123456', // remove this line if you don't need password
  showSummary: false,
);

dio.interceptors.add(inspector.getDioRequestInterceptor());
```

see detail example

## HTTP version

The detail screen shows the negotiated **HTTP Version** (e.g. `HTTP/1.1`, `HTTP/2`,
`HTTP/3`) whenever it can be determined. The row is hidden when the protocol is
unknown.

Where the value comes from, per platform:

| Platform / adapter | Source | Result |
| --- | --- | --- |
| Default `IOHttpClientAdapter` (Android/iOS/desktop) | dio sets `Response.extra['httpVersion']` | `HTTP/1.0` or `HTTP/1.1` |
| Web (`BrowserHttpClientAdapter`) | `PerformanceResourceTiming.nextHopProtocol` | `HTTP/1.1`, `HTTP/2`, `HTTP/3` |
| `cronet_http` / `cupertino_http` (native) | a bridge writes the protocol into `Response.extra` | `HTTP/2`, `HTTP/3` |

> On the web the protocol is read from the Resource Timing API. For cross-origin
> responses the server must send the `Timing-Allow-Origin` header, otherwise the
> browser hides `nextHopProtocol` and the row is omitted.

### Showing HTTP/2 and HTTP/3 with native clients

`cronet_http` (Android) and `cupertino_http` (iOS/macOS) negotiate HTTP/2 and
HTTP/3, but dio reaches them through a `package:http` bridge that does not fill
`Response.extra`. The inspector reads the protocol from
`extra['httpVersion']`, `extra['negotiatedProtocol']` or `extra['protocol']` —
so a small adapter that forwards the negotiated protocol is all that is needed:

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:cronet_http/cronet_http.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// Routes Dio requests through a `package:http` [client] (cronet/cupertino) and
/// forwards the negotiated protocol into `ResponseBody.extra`, where
/// dio_request_inspector picks it up.
class NativeHttpVersionAdapter implements HttpClientAdapter {
  NativeHttpVersionAdapter(this.client);

  final http.Client client;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final request = http.StreamedRequest(options.method, options.uri)
      ..followRedirects = options.followRedirects
      ..maxRedirects = options.maxRedirects;
    options.headers.forEach((k, v) => request.headers[k] = '$v');

    if (requestStream != null) {
      unawaited(request.sink.addStream(requestStream).then((_) {
        request.sink.close();
      }));
    } else {
      unawaited(request.sink.close());
    }

    final response = await client.send(request);

    final body = ResponseBody(
      response.stream.cast<Uint8List>(),
      response.statusCode,
      statusMessage: response.reasonPhrase,
      isRedirect: response.isRedirect,
      headers: response.headers.map((k, v) => MapEntry(k, [v])),
    );

    // cronet exposes the negotiated protocol (e.g. `h2`, `h3`, `http/1.1`).
    if (response is CronetStreamedResponse &&
        response.negotiatedProtocol.isNotEmpty) {
      body.extra['negotiatedProtocol'] = response.negotiatedProtocol;
    }
    return body;
  }

  @override
  void close({bool force = false}) => client.close();
}
```

Wire it up:

```dart
final dio = Dio()
  ..httpClientAdapter = NativeHttpVersionAdapter(CronetClient.defaultCronet())
  ..interceptors.add(inspector.getDioRequestInterceptor());
```

> `cupertino_http` does not expose the negotiated protocol through its public
> API, so on iOS use the default `IOHttpClientAdapter` (reports `HTTP/1.1`) if
> you need the version shown.

## Note

- tap ```Long press``` on your screen to show DioRequestInspector UI
