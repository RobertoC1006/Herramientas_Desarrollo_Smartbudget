import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<User?> {
  late final AuthRepository _authRepository;

  @override
  Future<User?> build() async {
    _authRepository = ref.read(authRepositoryProvider);

    try {
      final profile = await _authRepository.fetchProfile();
      return profile.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _authRepository.login(email, password);

      final profile = await _authRepository.fetchProfile();

      return profile.user;
    });
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final response = await _authRepository.register(nombre, email, password);

      await _authRepository.login(email, password);

      return response.user;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    await _authRepository.logout();

    state = const AsyncValue.data(null);
  }
}
