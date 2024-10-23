import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_aquarium_app/main.dart';

void main() {
  testWidgets('Aquarium app has the necessary elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(AquariumApp());

    expect(find.byType(Container), findsOneWidget);

    expect(find.text('Add Fish'), findsOneWidget);

    expect(find.text('Save Settings'), findsOneWidget);

    expect(find.byType(Slider), findsOneWidget);

    expect(find.byType(DropdownButton<Color>), findsOneWidget);
  });
}
