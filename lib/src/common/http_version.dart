import 'package:dio/dio.dart';

import 'http_version_web_resolver.dart';

/// Resolves the negotiated HTTP protocol for a Dio [Response] across platforms.
///
/// Different client adapters expose the protocol differently:
/// * dio's built-in `IOHttpClientAdapter` populates `extra['httpVersion']`
///   (e.g. `1.0`, `1.1`);
/// * native adapters (cronet/cupertino via a bridge) can forward their
///   negotiated protocol into `extra` under one of [_extraKeys];
/// * on the web nothing is exposed through the request, so the Resource Timing
///   API is queried as a fallback.
class HttpVersion {
  HttpVersion._();

  /// Candidate `extra` keys, in priority order, that an adapter may use to
  /// report the negotiated protocol.
  static const List<String> _extraKeys = <String>[
    HttpClientAdapter.extraKeyHttpVersion, // 'httpVersion' — dio IO adapter
    'negotiatedProtocol', // cronet_http's CronetStreamedResponse
    'protocol',
  ];

  /// Returns the raw protocol string for [response], or `null` if it cannot be
  /// determined. Use [formatHttpVersion] to turn it into a display label.
  static String? resolve(Response<dynamic> response) {
    for (final key in _extraKeys) {
      final value = response.extra[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return resolveWebHttpVersion(response.requestOptions.uri.toString());
  }

  /// Normalizes a raw protocol string (`extra` value, ALPN id or cronet's
  /// `negotiatedProtocol`) into a readable label like `HTTP/2`.
  ///
  /// Returns `null` for empty/unknown values so the UI can hide the field.
  static String? formatHttpVersion(String? version) {
    if (version == null) {
      return null;
    }
    final raw = version.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'unknown') {
      return null;
    }

    final v = raw.toLowerCase();

    // Already a friendly "http/x.y" label.
    if (v.startsWith('http/')) {
      return 'HTTP/${raw.substring(5)}';
    }

    // ALPN / negotiated-protocol identifiers.
    if (v == 'h3' || v.startsWith('h3-') || v.contains('quic')) {
      return 'HTTP/3';
    }
    if (v == 'h2' || v == 'h2c') {
      return 'HTTP/2';
    }
    if (v.startsWith('spdy')) {
      return 'HTTP/2'; // SPDY — the predecessor negotiated as HTTP/2-class.
    }

    // dart:io protocolVersion: "1.0", "1.1", "2.0".
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(v)) {
      return 'HTTP/$raw';
    }

    // Unknown shape — show it as-is rather than dropping information.
    return raw.toUpperCase().startsWith('HTTP') ? raw : 'HTTP/$raw';
  }
}
