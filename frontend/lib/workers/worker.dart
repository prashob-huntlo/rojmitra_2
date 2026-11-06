class Company {
  const Company({required this.id, required this.name});

  final String id;
  final String name;
}

class WorkEntry {
  const WorkEntry({
    required this.id,
    this.companyId,
    this.companyName,
    this.trade,
    required this.startDate,
    this.endDate,
    this.yearsOfExperience,
  });

  final String id;
  final String? companyId;
  final String? companyName;
  final String? trade;
  final DateTime startDate;
  final DateTime? endDate;
  final int? yearsOfExperience;

  bool get isCurrent => endDate == null;

  factory WorkEntry.fromJson(Map<String, dynamic> json) {
    final company = json['companyId'];
    String? companyId;
    String? companyName;
    if (company is Map) {
      companyId = company['id']?.toString() ?? company['_id']?.toString();
      companyName = company['name']?.toString();
    } else if (company != null) {
      companyId = company.toString();
    }

    final skill = json['skillId'];
    String? trade;
    if (skill is Map) {
      trade = skill['name']?.toString();
    }

    return WorkEntry(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      companyId: companyId,
      companyName: companyName,
      trade: trade,
      startDate: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: null,
      yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
    );
  }

  WorkEntry copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? trade,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    int? yearsOfExperience,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      trade: trade ?? this.trade,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }
}

class WorkerDocument {
  const WorkerDocument({
    required this.type,
    this.imagePath,
    this.side,
  });

  final DocumentType type;
  final String? imagePath;
  final DocumentSide? side;
}

enum DocumentSide { front, back }

enum DocumentType {
  aadhaar,
  pan,
  bankPassbook,
  drivingLicence,
  photo,
}

class Address {
  const Address({
    required this.addressLine,
    required this.villageOrTown,
    required this.district,
    required this.state,
    required this.pincode,
  });

  final String addressLine;
  final String villageOrTown;
  final String district;
  final String state;
  final String pincode;

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Address(
        addressLine: '',
        villageOrTown: '',
        district: '',
        state: '',
        pincode: '',
      );
    }
    return Address(
      addressLine: json['line']?.toString() ?? json['addressLine']?.toString() ?? '',
      villageOrTown: json['villageOrTown']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toApiJson() => {
        'line': addressLine,
        'villageOrTown': villageOrTown,
        'district': district,
        'state': state,
        'pincode': pincode,
      };

  Address copyWith({
    String? addressLine,
    String? villageOrTown,
    String? district,
    String? state,
    String? pincode,
  }) {
    return Address(
      addressLine: addressLine ?? this.addressLine,
      villageOrTown: villageOrTown ?? this.villageOrTown,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  bool isSameAs(Address other) {
    return addressLine == other.addressLine &&
        villageOrTown == other.villageOrTown &&
        district == other.district &&
        state == other.state &&
        pincode == other.pincode;
  }
}

class WorkerPersonal {
  const WorkerPersonal({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.permanentAddress,
    required this.currentAddress,
    this.hasDisability = false,
    this.disabilityDetails,
  });

  final String fullName;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final Address permanentAddress;
  final Address currentAddress;
  final bool hasDisability;
  final String? disabilityDetails;

  WorkerPersonal copyWith({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    Address? permanentAddress,
    Address? currentAddress,
    bool? hasDisability,
    String? disabilityDetails,
  }) {
    return WorkerPersonal(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      currentAddress: currentAddress ?? this.currentAddress,
      hasDisability: hasDisability ?? this.hasDisability,
      disabilityDetails: disabilityDetails ?? this.disabilityDetails,
    );
  }
}

class WorkerExperience {
  const WorkerExperience({
    required this.primaryTrade,
    required this.subSkills,
    required this.yearsOfExperience,
    required this.dailyWageExpected,
  });

  final String primaryTrade;
  final List<String> subSkills;
  final int yearsOfExperience;
  final int dailyWageExpected;

  WorkerExperience copyWith({
    String? primaryTrade,
    List<String>? subSkills,
    int? yearsOfExperience,
    int? dailyWageExpected,
  }) {
    return WorkerExperience(
      primaryTrade: primaryTrade ?? this.primaryTrade,
      subSkills: subSkills ?? this.subSkills,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      dailyWageExpected: dailyWageExpected ?? this.dailyWageExpected,
    );
  }
}

class Worker {
  const Worker({
    required this.id,
    required this.personal,
    required this.experience,
    required this.documents,
    required this.workHistory,
    required this.isReadyToWork,
    this.idType,
    this.maskedIdentity,
    this.primaryTradeId,
  });

  final String id;
  final WorkerPersonal personal;
  final WorkerExperience experience;
  final List<WorkerDocument> documents;
  final List<WorkEntry> workHistory;
  final bool isReadyToWork;
  final String? idType;
  final String? maskedIdentity;
  final String? primaryTradeId;

  /// Available for work when ready; "on a job" when not.
  bool get isCurrentlyWorking => !isReadyToWork;

  bool get isAvailable => isReadyToWork;

  List<WorkEntry> get sortedWorkHistory {
    final entries = List<WorkEntry>.from(workHistory);
    entries.sort((a, b) => b.startDate.compareTo(a.startDate));
    return entries;
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    final permanent = Address.fromJson(
      json['permanentAddress'] is Map
          ? Map<String, dynamic>.from(json['permanentAddress'] as Map)
          : null,
    );
    final same = json['presentSameAsPermanent'] == true;
    final present = same
        ? permanent
        : Address.fromJson(
            json['presentAddress'] is Map
                ? Map<String, dynamic>.from(json['presentAddress'] as Map)
                : null,
          );

    final rawExperiences = json['workExperiences'];
    final workHistory = <WorkEntry>[];
    var maxYears = 0;
    if (rawExperiences is List) {
      for (final item in rawExperiences) {
        if (item is! Map) continue;
        final entry = WorkEntry.fromJson(Map<String, dynamic>.from(item));
        workHistory.add(entry);
        final years = entry.yearsOfExperience ?? 0;
        if (years > maxYears) maxYears = years;
      }
    }

    String tradeName = '';
    String? tradeId;
    final primaryTrade = json['primaryTrade'] ?? json['jobId'];
    if (primaryTrade is Map) {
      tradeId = primaryTrade['id']?.toString() ?? primaryTrade['_id']?.toString();
      tradeName = primaryTrade['name']?.toString() ?? '';
    } else if (primaryTrade != null) {
      tradeId = primaryTrade.toString();
    }

    final skillNames = <String>[];
    final skillIds = json['skillIds'];
    if (skillIds is List) {
      for (final skill in skillIds) {
        if (skill is Map && skill['name'] != null) {
          skillNames.add(skill['name'].toString());
        }
      }
    }

    final docs = <WorkerDocument>[];
    final documents = json['documents'];
    final idType = json['idType']?.toString();
    final primaryType =
        idType == 'pan' ? DocumentType.pan : DocumentType.aadhaar;
    if (documents is Map) {
      final front = documents['primaryIdFrontUrl']?.toString();
      final back = documents['primaryIdBackUrl']?.toString();
      final pan = documents['panCardUrl']?.toString();
      final photo = documents['photoUrl']?.toString();

      if (front != null && front.isNotEmpty) {
        docs.add(WorkerDocument(
          type: primaryType,
          imagePath: front,
          side: DocumentSide.front,
        ));
      }
      if (back != null && back.isNotEmpty) {
        docs.add(WorkerDocument(
          type: primaryType,
          imagePath: back,
          side: DocumentSide.back,
        ));
      }
      // Avoid a duplicate row when panCardUrl is the same object as the front ID.
      if (pan != null && pan.isNotEmpty && pan != front) {
        docs.add(WorkerDocument(
          type: DocumentType.pan,
          imagePath: pan,
        ));
      }
      if (photo != null && photo.isNotEmpty) {
        docs.add(WorkerDocument(
          type: DocumentType.photo,
          imagePath: photo,
        ));
      }
    }

    final dob = json['dateOfBirth'];
    String dobText = '';
    if (dob != null) {
      final parsed = DateTime.tryParse(dob.toString());
      dobText = parsed != null
          ? '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}'
          : dob.toString();
    }

    return Worker(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      idType: json['idType']?.toString(),
      maskedIdentity: json['maskedIdentity']?.toString(),
      primaryTradeId: tradeId,
      isReadyToWork: json['isReadyToWork'] == true,
      personal: WorkerPersonal(
        fullName: json['fullName']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        gender: json['gender']?.toString() ?? '',
        dateOfBirth: dobText,
        permanentAddress: permanent,
        currentAddress: present,
        hasDisability: json['hasDisability'] == true,
        disabilityDetails: json['disabilityDetails']?.toString(),
      ),
      experience: WorkerExperience(
        primaryTrade: tradeName.isEmpty ? '—' : tradeName,
        subSkills: skillNames,
        yearsOfExperience: maxYears,
        dailyWageExpected: (json['dailyWageExpected'] as num?)?.toInt() ?? 0,
      ),
      documents: docs,
      workHistory: workHistory,
    );
  }

  Worker copyWith({
    String? id,
    WorkerPersonal? personal,
    WorkerExperience? experience,
    List<WorkerDocument>? documents,
    List<WorkEntry>? workHistory,
    bool? isReadyToWork,
    String? idType,
    String? maskedIdentity,
    String? primaryTradeId,
  }) {
    return Worker(
      id: id ?? this.id,
      personal: personal ?? this.personal,
      experience: experience ?? this.experience,
      documents: documents ?? this.documents,
      workHistory: workHistory ?? this.workHistory,
      isReadyToWork: isReadyToWork ?? this.isReadyToWork,
      idType: idType ?? this.idType,
      maskedIdentity: maskedIdentity ?? this.maskedIdentity,
      primaryTradeId: primaryTradeId ?? this.primaryTradeId,
    );
  }
}

class CompanyWorkerLink {
  const CompanyWorkerLink({
    required this.worker,
    required this.isCurrent,
  });

  final Worker worker;
  final bool isCurrent;
}

String resolveCompanyName(WorkEntry entry) {
  if (entry.companyName != null && entry.companyName!.trim().isNotEmpty) {
    return entry.companyName!;
  }
  return entry.companyId ?? '';
}

List<CompanyWorkerLink> workersByCompany(
  String companyId,
  List<Worker> workers,
) {
  final links = <CompanyWorkerLink>[];
  for (final worker in workers) {
    var matched = false;
    for (final entry in worker.workHistory) {
      if (entry.companyId == companyId) {
        matched = true;
        break;
      }
    }
    if (matched) {
      links.add(
        CompanyWorkerLink(
          worker: worker,
          isCurrent: !worker.isReadyToWork,
        ),
      );
    }
  }
  links.sort((a, b) {
    if (a.isCurrent != b.isCurrent) {
      return a.isCurrent ? -1 : 1;
    }
    return a.worker.personal.fullName.compareTo(b.worker.personal.fullName);
  });
  return links;
}

String? companyNameForId(String companyId, List<Worker> workers) {
  for (final person in workers) {
    for (final entry in person.workHistory) {
      if (entry.companyId == companyId &&
          entry.companyName != null &&
          entry.companyName!.trim().isNotEmpty) {
        return entry.companyName;
      }
    }
  }
  return null;
}
