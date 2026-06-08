import 'package:dio_request_inspector/src/common/http_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpVersion.formatHttpVersion', () {
    test('returns null for empty/unknown values', () {
      expect(HttpVersion.formatHttpVersion(null), isNull);
      expect(HttpVersion.formatHttpVersion(''), isNull);
      expect(HttpVersion.formatHttpVersion('   '), isNull);
      expect(HttpVersion.formatHttpVersion('unknown'), isNull);
    });

    test('formats dart:io protocolVersion values', () {
      expect(HttpVersion.formatHttpVersion('1.0'), 'HTTP/1.0');
      expect(HttpVersion.formatHttpVersion('1.1'), 'HTTP/1.1');
      expect(HttpVersion.formatHttpVersion('2.0'), 'HTTP/2.0');
    });

    test('maps ALPN identifiers', () {
      expect(HttpVersion.formatHttpVersion('h2'), 'HTTP/2');
      expect(HttpVersion.formatHttpVersion('h2c'), 'HTTP/2');
      expect(HttpVersion.formatHttpVersion('h3'), 'HTTP/3');
      expect(HttpVersion.formatHttpVersion('h3-29'), 'HTTP/3');
    });

    test('maps cronet negotiatedProtocol values', () {
      expect(HttpVersion.formatHttpVersion('quic/1+spdy/3'), 'HTTP/3');
      expect(HttpVersion.formatHttpVersion('http/1.1'), 'HTTP/1.1');
      expect(HttpVersion.formatHttpVersion('spdy/3.1'), 'HTTP/2');
    });

    test('normalizes friendly labels and case', () {
      expect(HttpVersion.formatHttpVersion('HTTP/1.1'), 'HTTP/1.1');
      expect(HttpVersion.formatHttpVersion('H2'), 'HTTP/2');
    });
  });
}
