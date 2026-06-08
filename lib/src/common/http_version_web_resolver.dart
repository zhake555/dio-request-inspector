/// Platform-aware entry point for resolving the negotiated HTTP protocol.
///
/// On the web it reads the Resource Timing API; everywhere else it is a no-op
/// (the version comes from the adapter via `Response.extra`).
export 'http_version_web_resolver_stub.dart'
    if (dart.library.js_interop) 'http_version_web_resolver_web.dart';
