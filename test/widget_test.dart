// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:bnwems_mobile/app.dart';

void main() {
  testWidgets('App login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BnwemsApp());

    // Verify that the login screen title exists.
    expect(find.text('Đăng nhập tài khoản điều hành'), findsOneWidget);
    expect(find.text('Đăng Nhập Vận Hành'), findsOneWidget);
  });
}
