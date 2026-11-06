import '../../../workers/worker.dart' show Address;

enum AccountStatus { pending, accepted, rejected }

AccountStatus accountStatusFromJson(String value) {
  switch (value) {
    case 'accepted':
      return AccountStatus.accepted;
    case 'rejected':
      return AccountStatus.rejected;
    case 'pending':
    default:
      return AccountStatus.pending;
  }
}

/// Partner roles from the API: `csc` | `cmc` | `anganwadi` | `gov_ngo`.
class Partner {
  const Partner({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phoneNumber,
    required this.state,
    required this.district,
    required this.pincode,
    required this.status,
    this.email,
    this.avatarUrl,
    this.permanentAddress,
    this.presentAddress,
    this.presentSameAsPermanent = false,
    this.rejectionReason,
    this.profile = const {},
  });

  final String id;
  final String role;
  final String fullName;
  final String phoneNumber;
  final String? email;
  /// GCS object key for optional profile photo.
  final String? avatarUrl;
  final Address? permanentAddress;
  final Address? presentAddress;
  final bool presentSameAsPermanent;
  final String state;
  final String district;
  final String pincode;
  final AccountStatus status;
  final String? rejectionReason;
  final Map<String, dynamic> profile;

  factory Partner.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    final avatar = json['avatarUrl']?.toString();
    final permanent = json['permanentAddress'] is Map
        ? Address.fromJson(Map<String, dynamic>.from(json['permanentAddress'] as Map))
        : null;
    final same = json['presentSameAsPermanent'] == true;
    final present = same
        ? permanent
        : (json['presentAddress'] is Map
            ? Address.fromJson(Map<String, dynamic>.from(json['presentAddress'] as Map))
            : null);

    // Prefer structured address; fall back to legacy flat fields.
    final state = permanent?.state.isNotEmpty == true
        ? permanent!.state
        : (json['state'] as String? ?? '');
    final district = permanent?.district.isNotEmpty == true
        ? permanent!.district
        : (json['district'] as String? ?? '');
    final pincode = permanent?.pincode.isNotEmpty == true
        ? permanent!.pincode
        : (json['pincode'] as String? ?? '');

    return Partner(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
      permanentAddress: permanent,
      presentAddress: present,
      presentSameAsPermanent: same,
      state: state,
      district: district,
      pincode: pincode,
      status: accountStatusFromJson(json['status'] as String? ?? 'pending'),
      rejectionReason: json['rejectionReason'] as String?,
      profile: rawProfile is Map
          ? Map<String, dynamic>.from(rawProfile)
          : const {},
    );
  }
}
