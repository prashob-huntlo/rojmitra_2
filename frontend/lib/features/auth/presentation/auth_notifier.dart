import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../features/uploads/data/uploads_repository.dart';
import '../../../workers/worker_filters.dart';
import '../../../workers/workers_provider.dart';
import '../data/auth_repository.dart';
import '../models/partner.dart';
import 'partner_profile_provider.dart';

sealed class AuthState {
  const AuthState();
}

final class Initial extends AuthState {
  const Initial();
}

final class Loading extends AuthState {
  const Loading();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AwaitingApproval extends AuthState {
  const AwaitingApproval(this.partner);
  final Partner partner;
}

final class Rejected extends AuthState {
  const Rejected(this.partner, [this.reason]);
  final Partner partner;
  final String? reason;
}

final class Authenticated extends AuthState {
  const Authenticated(this.partner);
  final Partner partner;
}

AuthState authStateForPartner(Partner partner) {
  switch (partner.status) {
    case AccountStatus.pending:
      return AwaitingApproval(partner);
    case AccountStatus.rejected:
      return Rejected(partner, partner.rejectionReason);
    case AccountStatus.accepted:
      return Authenticated(partner);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const Initial();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  TokenStorage get _tokens => ref.read(tokenStorageProvider);

  /// Drop cached partner/workers/avatars so the next account never flashes the last one.
  void _clearUserScopedCaches() {
    ref.invalidate(partnerProfileProvider);
    ref.invalidate(workersProvider);
    ref.invalidate(workerFiltersProvider);
    ref.invalidate(signedReadUrlProvider);
  }

  Future<void> checkAuthStatus() async {
    state = const Loading();
    final token = await _tokens.getToken();
    if (token == null || token.isEmpty) {
      _clearUserScopedCaches();
      state = const Unauthenticated();
      return;
    }

    try {
      final partner = await _repo.fetchMe();
      state = authStateForPartner(partner);
    } on ApiError catch (e) {
      if (e.code == 'unauthorized' || e.statusCode == 401) {
        await _tokens.clearToken();
        _clearUserScopedCaches();
        state = const Unauthenticated();
        return;
      }
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> signup(Map<String, dynamic> body) async {
    state = const Loading();
    try {
      await _repo.signup(body);
      state = const Unauthenticated();
    } catch (_) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> sendOtp(String phoneNumber, String purpose) async {
    state = const Loading();
    try {
      await _repo.requestOtp(phoneNumber: phoneNumber, purpose: purpose);
      state = const Unauthenticated();
    } catch (_) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> submitOtp({
    required String phoneNumber,
    required String otp,
    required String purpose,
  }) async {
    state = const Loading();
    try {
      final token = await _repo.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        purpose: purpose,
      );
      await _completeLogin(token);
    } catch (_) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> loginWithPassword({
    required String phoneNumber,
    required String password,
  }) async {
    state = const Loading();
    try {
      final token = await _repo.loginWithPassword(
        phoneNumber: phoneNumber,
        password: password,
      );
      await _completeLogin(token);
    } catch (_) {
      state = const Unauthenticated();
      rethrow;
    }
  }

  Future<void> _completeLogin(String token) async {
    await _tokens.saveToken(token);
    _clearUserScopedCaches();
    final partner = await _repo.fetchMe();
    state = authStateForPartner(partner);
  }

  Future<void> logout() async {
    await _tokens.clearToken();
    _clearUserScopedCaches();
    state = const Unauthenticated();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
