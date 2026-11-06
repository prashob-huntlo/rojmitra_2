typedef PartnerProfileField = ({
  String key,
  String label,
  bool required,
  bool isPhone,
});

String partnerRoleLabel(String role) {
  switch (role) {
    case 'csc':
      return 'CSC';
    case 'cmc':
      return 'CMC';
    case 'anganwadi':
      return 'Anganwadi';
    case 'gov_ngo':
      return 'Gov / NGO';
    default:
      return role;
  }
}

String partnerProfileFieldLabel(String key) {
  final spaced = key.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  if (spaced.isEmpty) return key;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

/// Editable role-profile fields by partner channel.
List<PartnerProfileField> partnerProfileFieldsForRole(String role) {
  switch (role) {
    case 'csc':
      return const [
        (key: 'vleId', label: 'VLE ID', required: true, isPhone: false),
        (key: 'kioskName', label: 'Kiosk name', required: true, isPhone: false),
      ];
    case 'cmc':
      return const [
        (
          key: 'agencyOrPartnerName',
          label: 'Agency / partner name',
          required: true,
          isPhone: false,
        ),
        (
          key: 'supervisorName',
          label: 'Supervisor name',
          required: true,
          isPhone: false,
        ),
        (
          key: 'supervisorPhone',
          label: 'Supervisor phone',
          required: true,
          isPhone: true,
        ),
        (
          key: 'mobilizerId',
          label: 'Mobilizer ID (optional)',
          required: false,
          isPhone: false,
        ),
      ];
    case 'anganwadi':
      return const [
        (key: 'awcCode', label: 'AWC code', required: true, isPhone: false),
        (
          key: 'centerName',
          label: 'Center name',
          required: true,
          isPhone: false,
        ),
      ];
    case 'gov_ngo':
      return const [
        (
          key: 'organizationName',
          label: 'Organization name',
          required: true,
          isPhone: false,
        ),
        (
          key: 'designation',
          label: 'Designation',
          required: true,
          isPhone: false,
        ),
      ];
    default:
      return const [];
  }
}
