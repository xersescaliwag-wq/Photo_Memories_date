import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:photomemoriesdate/main.dart';
import 'package:photomemoriesdate/services/api_service.dart';
import 'package:photomemoriesdate/services/auth_service.dart';

class FakeApiService extends ApiService {
  @override
  Future<AuthUser> register(
    String username,
    String email,
    String password,
  ) async {
    return const AuthUser(userId: 1, username: 'Geof', email: 'geof@mail.com');
  }

  @override
  Future<AuthUser> login(String identifier, String password) async {
    return const AuthUser(userId: 1, username: 'Geof', email: 'geof@mail.com');
  }

  @override
  Future<List<MemoryData>> getMemories(int userId) async => const [];

  @override
  Future<void> deleteMemory(int userId, String dateKey) async {}

  @override
  Future<bool> ping() async => true;

  @override
  Future<void> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {}
}

void main() {
  testWidgets('App starts on login screen when logged out', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final AuthService auth = AuthService(api: FakeApiService());
    await auth.init();

    await tester.pumpWidget(
      LiquidGlassWidgets.wrap(
        child: AppRoot(auth: auth, api: FakeApiService()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(auth.isLoggedIn, isFalse);
    expect(find.text('Memories'), findsOneWidget);
    expect(find.text('ENTER GALLERY'), findsOneWidget);
  });

  test('Register logs the user in through the API', () async {
    SharedPreferences.setMockInitialValues({});
    final AuthService auth = AuthService(api: FakeApiService());
    await auth.init();

    expect(auth.isLoggedIn, isFalse);
    final bool ok = await auth.register('Geof', 'geof@mail.com', 'secret123');
    expect(ok, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.userId, 1);
  });
}