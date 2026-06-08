/// Fallback resolver for non-web platforms.
///
/// On IO platforms the negotiated HTTP protocol is reported by the client
/// adapter through `Response.extra`, so there is nothing to resolve here.
String? resolveWebHttpVersion(String url) => null;
