import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({Map<String, dynamic>? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await ApiClient().init();
    try {
      final user = await _authService.getStoredUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await _authService.login(email, password);
      state = AsyncValue.data(data['user']);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> register(String name, String email, String password, {String phone = ''}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _authService.register(name, email, password, phone: phone);
      state = AsyncValue.data(data['user']);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return AuthNotifier(AuthService());
});
