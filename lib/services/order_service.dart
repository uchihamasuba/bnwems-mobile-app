import '../services/api_service.dart';
import '../models/order_model.dart';

class OrderService {
  /// GET /api/v1/orders
  static Future<List<OrderModel>> getOrders({String? status}) async {
    final queryParams = status != null ? '?status=$status' : '';
    final response = await ApiService.get('/orders$queryParams');
    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/v1/orders/:id
  static Future<OrderModel> getOrderById(int id) async {
    final response = await ApiService.get('/orders/$id');
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
