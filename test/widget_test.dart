import 'package:bnwems_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App routes unauthenticated users to login screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BnwemsApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Binh Nguyen Wedding & Event'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
