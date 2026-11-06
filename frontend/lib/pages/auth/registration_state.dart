import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'signup_channel.dart';

class RegistrationState {
  const RegistrationState({this.channel});

  final SignupChannel? channel;

  RegistrationState copyWith({SignupChannel? channel}) {
    return RegistrationState(channel: channel ?? this.channel);
  }
}

class RegistrationNotifier extends Notifier<RegistrationState> {
  @override
  RegistrationState build() => const RegistrationState();

  void setChannel(SignupChannel channel) {
    state = state.copyWith(channel: channel);
  }

  void clear() {
    state = const RegistrationState();
  }
}

final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
  RegistrationNotifier.new,
);
