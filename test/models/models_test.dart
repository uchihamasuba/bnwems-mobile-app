import 'package:flutter_test/flutter_test.dart';
import 'package:bnwems_mobile/models/user_model.dart';
import 'package:bnwems_mobile/models/order_model.dart';

void main() {
  group('UserModel', () {
    const validJson = {
      'id': 1,
      'username': 'leader_tuan',
      'fullName': 'Trần Văn Tuấn',
      'email': 'tuan.tv@bnwems.vn',
      'phone': '0901234567',
      'status': 'ACTIVE',
      'role': {
        'id': 3,
        'roleName': 'Leader Staff',
        'permissions': ['VIEW_ASSIGNED_ORDERS', 'RECORD_ATTENDANCE'],
      },
    };

    test('fromJson — should parse all fields correctly', () {
      final user = UserModel.fromJson(validJson);
      expect(user.id, 1);
      expect(user.username, 'leader_tuan');
      expect(user.fullName, 'Trần Văn Tuấn');
      expect(user.email, 'tuan.tv@bnwems.vn');
      expect(user.phone, '0901234567');
      expect(user.status, 'ACTIVE');
      expect(user.role.roleName, 'Leader Staff');
      expect(user.role.permissions, contains('RECORD_ATTENDANCE'));
    });

    test('fromJson — should handle null phone gracefully', () {
      final jsonWithNullPhone = {...validJson, 'phone': null};
      final user = UserModel.fromJson(jsonWithNullPhone);
      expect(user.phone, isNull);
    });

    test('toJson — should serialize back to correct map', () {
      final user = UserModel.fromJson(validJson);
      final json = user.toJson();
      expect(json['id'], 1);
      expect(json['username'], 'leader_tuan');
      expect(json['status'], 'ACTIVE');
      expect((json['role'] as Map)['roleName'], 'Leader Staff');
    });

    test('fromJson — should handle empty permissions list', () {
      final jsonNoPerms = {
        ...validJson,
        'role': {'id': 1, 'roleName': 'Administrator'},
      };
      final user = UserModel.fromJson(jsonNoPerms);
      expect(user.role.permissions, isEmpty);
    });
  });

  group('OrderModel', () {
    final validOrderJson = {
      'id': 88,
      'orderCode': 'ORD-2026-0088',
      'status': 'EXECUTING',
      'eventDate': '2026-12-20T08:00:00.000Z',
      'eventLocation': 'Alpha Event Hall, HCM City',
      'notes': 'Outdoor setup required.',
      'customer': {
        'fullName': 'Nguyễn Thị Bình',
        'phone': '0901122334',
      },
      'createdAt': '2026-06-01T10:00:00.000Z',
    };

    test('fromJson — should parse order and customer fields', () {
      final order = OrderModel.fromJson(validOrderJson);
      expect(order.id, 88);
      expect(order.orderCode, 'ORD-2026-0088');
      expect(order.status, 'EXECUTING');
      expect(order.eventDate.year, 2026);
      expect(order.eventDate.month, 12);
      expect(order.customer?.fullName, 'Nguyễn Thị Bình');
      expect(order.customer?.phone, '0901122334');
    });

    test('fromJson — should handle null customer', () {
      final orderNoCustomer = {...validOrderJson, 'customer': null};
      final order = OrderModel.fromJson(orderNoCustomer);
      expect(order.customer, isNull);
    });

    test('fromJson — should handle null notes', () {
      final orderNoNotes = {...validOrderJson, 'notes': null};
      final order = OrderModel.fromJson(orderNoNotes);
      expect(order.notes, isNull);
    });

    test('toJson — should serialize back correctly', () {
      final order = OrderModel.fromJson(validOrderJson);
      final json = order.toJson();
      expect(json['orderCode'], 'ORD-2026-0088');
      expect(json['status'], 'EXECUTING');
    });
  });
}
