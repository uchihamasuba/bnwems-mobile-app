import 'package:bnwems_mobile/models/order_model.dart';
import 'package:bnwems_mobile/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    const validJson = {
      'id': 'user-001',
      'username': 'leader_tuan',
      'fullName': 'Tran Van Tuan',
      'status': 'ACTIVE',
      'role': 'LEADER_STAFF',
    };

    test('fromJson should parse backend login payload', () {
      final user = UserModel.fromJson(validJson);
      expect(user.id, 'user-001');
      expect(user.username, 'leader_tuan');
      expect(user.fullName, 'Tran Van Tuan');
      expect(user.status, 'ACTIVE');
      expect(user.role, 'LEADER_STAFF');
      expect(user.isLeader, isTrue);
    });

    test('role helpers should identify dashboards correctly', () {
      final manager = UserModel.fromJson({...validJson, 'role': 'MANAGER'});
      final technical =
          UserModel.fromJson({...validJson, 'role': 'TECHNICAL_STAFF'});

      expect(manager.isManager, isTrue);
      expect(manager.canUseMobileApp, isTrue);
      expect(manager.isLeader, isFalse);
      expect(technical.isTechnical, isTrue);
    });

    test('fromJson should normalize backend role names', () {
      final manager = UserModel.fromJson({
        ...validJson,
        'role': {'roleName': 'Manager'}
      });
      final leader = UserModel.fromJson({
        ...validJson,
        'role': {'roleName': 'Leader Staff'}
      });
      final admin = UserModel.fromJson({
        ...validJson,
        'role': {'roleName': 'Admin'}
      });

      expect(manager.role, 'MANAGER');
      expect(leader.role, 'LEADER_STAFF');
      expect(admin.isAdmin, isTrue);
      expect(admin.canUseMobileApp, isFalse);
    });

    test('toJson should serialize back to correct map', () {
      final user = UserModel.fromJson(validJson);
      final json = user.toJson();
      expect(json['id'], 'user-001');
      expect(json['username'], 'leader_tuan');
      expect(json['status'], 'ACTIVE');
      expect(json['role'], 'LEADER_STAFF');
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
        'fullName': 'Nguyen Thi Binh',
        'phone': '0901122334',
      },
      'createdAt': '2026-06-01T10:00:00.000Z',
    };

    test('fromJson should parse order and customer fields', () {
      final order = OrderModel.fromJson(validOrderJson);
      expect(order.id, 88);
      expect(order.orderCode, 'ORD-2026-0088');
      expect(order.status, 'EXECUTING');
      expect(order.eventDate.year, 2026);
      expect(order.eventDate.month, 12);
      expect(order.customer?.fullName, 'Nguyen Thi Binh');
      expect(order.customer?.phone, '0901122334');
    });

    test('fromJson should handle null customer', () {
      final orderNoCustomer = {...validOrderJson, 'customer': null};
      final order = OrderModel.fromJson(orderNoCustomer);
      expect(order.customer, isNull);
    });

    test('fromJson should handle null notes', () {
      final orderNoNotes = {...validOrderJson, 'notes': null};
      final order = OrderModel.fromJson(orderNoNotes);
      expect(order.notes, isNull);
    });

    test('toJson should serialize back correctly', () {
      final order = OrderModel.fromJson(validOrderJson);
      final json = order.toJson();
      expect(json['orderCode'], 'ORD-2026-0088');
      expect(json['status'], 'EXECUTING');
    });
  });
}
