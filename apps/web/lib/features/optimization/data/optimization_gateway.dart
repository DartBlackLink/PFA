import '../../../core/network/api_client.dart';

typedef Records = List<Map<String, dynamic>>;

abstract class OptimizationGateway {
  Future<Map<String, Records>> load();
  Future<Map<String, dynamic>> preview(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> confirm(String identifier);
  Future<Map<String, dynamic>> getPlan(String identifier);
}

class HttpOptimizationGateway implements OptimizationGateway {
  HttpOptimizationGateway(this.client);
  final ApiClient client;

  @override
  Future<Map<String, Records>> load() async {
    final data = await Future.wait(
      [
        '/orders/?limit=1000&estado=PENDIENTE',
        '/drivers/?limit=1000',
        '/vehicles/?limit=1000',
        '/optimizations/',
      ].map(client.request),
    );
    return {
      for (var i = 0; i < data.length; i++)
        ['orders', 'drivers', 'vehicles', 'plans'][i]: (data[i] as List)
            .cast<Map<String, dynamic>>(),
    };
  }

  @override
  Future<Map<String, dynamic>> preview(Map<String, dynamic> payload) async =>
      Map<String, dynamic>.from(
        await client.request(
          '/optimizations/preview',
          method: 'POST',
          body: payload,
        ),
      );

  @override
  Future<Map<String, dynamic>> confirm(String identifier) async =>
      Map<String, dynamic>.from(
        await client.request(
          '/optimizations/$identifier/confirm',
          method: 'POST',
        ),
      );

  @override
  Future<Map<String, dynamic>> getPlan(String identifier) async =>
      Map<String, dynamic>.from(
        await client.request('/optimizations/$identifier'),
      );
}
