import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartbudget/app.dart';
import 'package:smartbudget/features/auth/auth_controller.dart';
import 'package:smartbudget/data/repositories/auth_repository.dart';
import 'package:smartbudget/data/models/user.dart';

class FakeAuthRepository extends AuthRepository {
  @override
  Future<UserResponse> fetchProfile() async {
    throw Exception('Not authenticated');
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const SmartBugdetApp(),
      ),
    );

    // Verify that the login screen is loaded (contains the title "SmartBudget+")
    expect(find.text('SmartBudget+'), findsWidgets);
  });
}
