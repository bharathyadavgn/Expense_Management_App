import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/hardcoded_users.dart';
import '../core/database/db_helper.dart';

class UserSession {
  final int id;
  final String name;
  final String role;

  UserSession({required this.id, required this.name, required this.role});
}

class AuthState {
  final UserSession? user;
  final bool loading;
  final String? error;

  AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({UserSession? user, bool? loading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String username, String password, String role) async {
    state = state.copyWith(loading: true, error: null);

    try {
      //  Hardcoded Users
      final hardcoded = HardcodedUsers.authenticate(username, password, role);
      if (hardcoded != null) {
        state = state.copyWith(
          user: UserSession(
            id: hardcoded.id,
            name: hardcoded.username,
            role: hardcoded.role,
          ),
          loading: false,
        );
        return;
      }

      // DB FALLBACK LOGIN
      final db = await DBHelper.database;
      final email = '$username@company.com';

      final maps = await db.query(
        'users',
        where: 'email = ? AND role = ?',
        whereArgs: [email, role],
      );

      if (maps.isNotEmpty) {
        final row = maps.first;
        state = state.copyWith(
          user: UserSession(
            id: row['id'] as int,
            name: row['name'] as String,
            role: row['role'] as String,
          ),
          loading: false,
        );
        return;
      }

      state = state.copyWith(error: 'Invalid credentials or role', loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(),
);
