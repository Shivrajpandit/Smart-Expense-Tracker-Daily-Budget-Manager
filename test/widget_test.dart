import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/data/database/app_database.dart';
import 'package:spendwise/presentation/providers/database_provider.dart';
import 'package:spendwise/presentation/screens/main_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SpendWise main screen smoke test', (WidgetTester tester) async {
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify app title and navigation items exist
    expect(find.text('SpendWise'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await inMemoryDb.close();
  });
}
