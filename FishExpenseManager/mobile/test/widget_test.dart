import 'package:fish_business_manager/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Nút chính hiển thị nhãn và nhận thao tác', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Sao lưu ngay',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Sao lưu ngay'), findsOneWidget);
    await tester.tap(find.text('Sao lưu ngay'));
    expect(pressed, isTrue);
  });
}
