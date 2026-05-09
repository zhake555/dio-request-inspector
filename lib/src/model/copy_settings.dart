class CopySettings {
  final bool copyRequestHeaders;
  final bool copyResponseHeaders;
  final List<String> excludedHeaders;

  const CopySettings({
    this.copyRequestHeaders = true,
    this.copyResponseHeaders = true,
    this.excludedHeaders = const ['authorization'],
  });

  CopySettings copyWith({
    bool? copyRequestHeaders,
    bool? copyResponseHeaders,
    List<String>? excludedHeaders,
  }) {
    return CopySettings(
      copyRequestHeaders: copyRequestHeaders ?? this.copyRequestHeaders,
      copyResponseHeaders: copyResponseHeaders ?? this.copyResponseHeaders,
      excludedHeaders: excludedHeaders ?? this.excludedHeaders,
    );
  }
}
