/// Onboarding channel chosen before partner registration details.
enum SignupChannel {
  cscCentre,
  communityMobilizer,
  anganwadi,
  ngoPartner,
}

extension SignupChannelApi on SignupChannel {
  /// Backend `role` value for `POST /auth/signup`.
  String get apiRole => switch (this) {
        SignupChannel.cscCentre => 'csc',
        SignupChannel.communityMobilizer => 'cmc',
        SignupChannel.anganwadi => 'anganwadi',
        SignupChannel.ngoPartner => 'gov_ngo',
      };
}
