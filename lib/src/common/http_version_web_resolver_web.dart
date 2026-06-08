import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Resolves the negotiated HTTP protocol on the web.
///
/// Browsers don't expose the HTTP version through `XMLHttpRequest`/`fetch`, but
/// the Resource Timing API reports it via [PerformanceResourceTiming.nextHopProtocol]
/// (ALPN id, e.g. `h2`, `h3`, `http/1.1`).
///
/// Returns `null` when no timing entry is available yet or when the value is
/// hidden — cross-origin responses require the `Timing-Allow-Origin` header for
/// `nextHopProtocol` to be exposed.
String? resolveWebHttpVersion(String url) {
  try {
    final entries =
        web.window.performance.getEntriesByName(url, 'resource').toDart;
    // Multiple requests can hit the same URL; the latest entry is the freshest.
    for (final entry in entries.reversed) {
      if (entry.isA<web.PerformanceResourceTiming>()) {
        final protocol = (entry as web.PerformanceResourceTiming).nextHopProtocol;
        if (protocol.isNotEmpty) {
          return protocol;
        }
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}
