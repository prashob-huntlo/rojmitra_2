import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountStatus { pending, accepted, rejected }

class AuthSession {
  const AuthSession({required this.phone, required this.status});

  final String phone;
  final AccountStatus status;

  bool get isPending => status == AccountStatus.pending;
}

class AuthSessionNotifier extends Notifier<AuthSession?> {
  final Set<String> _pendingPhones = {};

  @override
  AuthSession? build() => null;

  void submitForApproval(String phone) {
    _pendingPhones.add(phone);
    state = AuthSession(phone: phone, status: AccountStatus.pending);
  }

  AuthSession signIn(String phone) {
    final session = AuthSession(
      phone: phone,
      status: _pendingPhones.contains(phone)
          ? AccountStatus.pending
          : AccountStatus.accepted,
    );
    state = session;
    return session;
  }

  void signOut() {
    state = null;
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSession?>(AuthSessionNotifier.new);
