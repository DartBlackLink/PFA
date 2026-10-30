/// Public connection setting. Backend secrets are never loaded as Flutter assets.
class EntornoConfig {
  static const _configured = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static String get apiBaseUrl {
    final uri = Uri.tryParse(_configured);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw StateError('Configura una dirección pública de API válida.');
    }
    return _configured.endsWith('/')
        ? _configured.substring(0, _configured.length - 1)
        : _configured;
  }
}
