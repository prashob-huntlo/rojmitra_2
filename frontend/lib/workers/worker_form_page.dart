import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/l10n/app_localizations.dart';
import '../core/errors/api_error.dart';
import '../core/ui/date_slash_formatter.dart';
import '../features/catalog/models/catalog_job.dart';
import '../features/catalog/presentation/job_search_field.dart';
import '../features/uploads/data/uploads_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import 'add_work_sheet.dart';
import 'address_fields.dart';
import 'availability_chip.dart';
import 'worker.dart';
import 'workers_provider.dart';
import 'work_history_tile.dart';

class WorkerFormPage extends ConsumerStatefulWidget {
  const WorkerFormPage({
    super.key,
    this.workerId,
    this.initialTabIndex = 0,
  });

  final String? workerId;
  final int initialTabIndex;

  bool get isEditing => workerId != null;

  @override
  ConsumerState<WorkerFormPage> createState() => _WorkerFormPageState();
}

class _WorkerFormPageState extends ConsumerState<WorkerFormPage>
    with SingleTickerProviderStateMixin {
  static const _idTypes = ['aadhaar', 'pan'];
  static const _genders = ['male', 'female', 'other'];

  final _formKey = GlobalKey<FormState>();
  final _dobFieldKey = GlobalKey<FormFieldState<String>>();
  final _imagePicker = ImagePicker();
  late final TabController _tabController;

  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _dateOfBirth;
  late final TextEditingController _idNumber;
  late final TextEditingController _years;
  late final TextEditingController _wage;
  late final TextEditingController _disabilityDetails;
  late final AddressControllers _permanentAddress;
  late final AddressControllers _currentAddress;

  String? _gender;
  String? _idType;
  String? _maskedIdentity;
  CatalogJob? _primaryTrade;
  String? _idFrontPath;
  String? _idBackPath;
  String? _idFrontKey;
  String? _idBackKey;
  bool _hasDisability = false;
  bool _sameAsPermanent = false;
  bool _missingWorker = false;
  bool _saving = false;
  late List<WorkEntry> _workHistory;

  @override
  void initState() {
    super.initState();
    final tabIndex = widget.initialTabIndex.clamp(0, 2).toInt();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: tabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    final existing = widget.workerId == null
        ? null
        : ref.read(workersProvider.notifier).findById(widget.workerId!);

    if (widget.isEditing && existing == null) {
      _missingWorker = true;
    }

    final personal = existing?.personal;
    final experience = existing?.experience;

    _fullName = TextEditingController(text: personal?.fullName ?? '');
    _phone = TextEditingController(text: personal?.phoneNumber ?? '');
    _dateOfBirth = TextEditingController(text: personal?.dateOfBirth ?? '');
    _idNumber = TextEditingController();
    _years = TextEditingController(
      text: experience?.yearsOfExperience.toString() ?? '',
    );
    _wage = TextEditingController(
      text: experience?.dailyWageExpected.toString() ?? '',
    );
    _hasDisability = personal?.hasDisability ?? false;
    _disabilityDetails = TextEditingController(
      text: personal?.disabilityDetails ?? '',
    );
    _permanentAddress = AddressControllers(initial: personal?.permanentAddress);
    _currentAddress = AddressControllers(initial: personal?.currentAddress);
    _sameAsPermanent = personal != null &&
        personal.permanentAddress.isSameAs(personal.currentAddress);
    _permanentAddress.addListener(_syncCurrentFromPermanent);
    _workHistory = List<WorkEntry>.from(existing?.workHistory ?? const []);

    final existingGender = personal?.gender.toLowerCase();
    if (existingGender != null && _genders.contains(existingGender)) {
      _gender = existingGender;
    }

    if (existing?.primaryTradeId != null &&
        existing!.experience.primaryTrade.isNotEmpty &&
        existing.experience.primaryTrade != '—') {
      _primaryTrade = CatalogJob(
        id: existing.primaryTradeId!,
        name: existing.experience.primaryTrade,
      );
    }
    if (existing?.idType != null && _idTypes.contains(existing!.idType)) {
      _idType = existing.idType!;
    }
    _maskedIdentity = existing?.maskedIdentity;

    if (existing != null) {
      for (final doc in existing.documents) {
        final key = doc.imagePath;
        if (key == null || key.isEmpty) continue;
        if (doc.side == DocumentSide.front) {
          _idFrontKey = key;
        } else if (doc.side == DocumentSide.back) {
          _idBackKey = key;
        }
      }
      // Fallback if side wasn't tagged.
      if (_idFrontKey == null) {
        for (final doc in existing.documents) {
          if (doc.imagePath != null && doc.imagePath!.isNotEmpty) {
            _idFrontKey ??= doc.imagePath;
            break;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullName.dispose();
    _phone.dispose();
    _dateOfBirth.dispose();
    _idNumber.dispose();
    _years.dispose();
    _wage.dispose();
    _disabilityDetails.dispose();
    _permanentAddress.removeListener(_syncCurrentFromPermanent);
    _permanentAddress.dispose();
    _currentAddress.dispose();
    super.dispose();
  }

  String? _required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.requiredField;
    }
    return null;
  }

  String _idTypeLabel(AppLocalizations l10n, String type) {
    return type == 'pan' ? l10n.pan : l10n.aadhaar;
  }

  String _genderLabel(AppLocalizations l10n, String gender) {
    switch (gender) {
      case 'female':
        return l10n.female;
      case 'other':
        return l10n.other;
      default:
        return l10n.male;
    }
  }

  /// Looks like a text field; opens a tight popup under the field (not M3's big menu card).
  Widget _formDropdown({
    required String? value,
    required String label,
    required String hint,
    required List<String> options,
    required String Function(String value) optionLabel,
    required ValueChanged<String?> onChanged,
    required AppLocalizations l10n,
  }) {
    return FormField<String>(
      initialValue: value,
      validator: (selected) => selected == null ? l10n.requiredField : null,
      builder: (field) {
        return _CompactSelectField(
          label: label,
          hint: hint,
          value: field.value,
          errorText: field.errorText,
          optionLabel: optionLabel,
          options: options,
          onChanged: (selected) {
            field.didChange(selected);
            onChanged(selected);
          },
        );
      },
    );
  }

  void _syncCurrentFromPermanent() {
    if (!_sameAsPermanent) return;
    _currentAddress.copyFrom(_permanentAddress);
  }

  void _onSameAsPermanentChanged(bool? value) {
    final checked = value ?? false;
    setState(() {
      _sameAsPermanent = checked;
      if (checked) {
        _currentAddress.copyFrom(_permanentAddress);
      }
    });
  }

  void _onIdTypeChanged(String? value) {
    if (value == _idType) return;
    setState(() {
      _idType = value;
      _idNumber.clear();
      _idFrontPath = null;
      _idBackPath = null;
      _idFrontKey = null;
      _idBackKey = null;
    });
  }

  String? _validateIdNumber(String? value, AppLocalizations l10n) {
    final requiredError = _required(value, l10n);
    if (requiredError != null) return requiredError;
    final raw = value!.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (_idType == 'aadhaar') {
      if (!RegExp(r'^\d{12}$').hasMatch(raw)) return l10n.invalidAadhaar;
    } else if (_idType == 'pan') {
      if (!RegExp(r'^[A-Za-z]{5}[0-9]{4}[A-Za-z]$').hasMatch(raw)) {
        return l10n.invalidPan;
      }
    }
    return null;
  }

  bool get _hasFrontImage =>
      (_idFrontPath != null && _idFrontPath!.isNotEmpty) ||
      (_idFrontKey != null && _idFrontKey!.isNotEmpty);

  bool get _hasBackImage =>
      (_idBackPath != null && _idBackPath!.isNotEmpty) ||
      (_idBackKey != null && _idBackKey!.isNotEmpty);

  Future<void> _pickIdImage({required bool isFront}) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chooseGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) return;

    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (file == null || !mounted) return;

    setState(() {
      if (isFront) {
        _idFrontPath = file.path;
      } else {
        _idBackPath = file.path;
      }
    });
  }

  Future<void> _addWork() async {
    final entry = await showAddWorkSheet(context);
    if (entry == null || !mounted) return;
    setState(() {
      _workHistory = [..._workHistory, entry];
    });
  }

  void _endWork(String entryId) {
    setState(() {
      _workHistory = [
        for (final entry in _workHistory)
          if (entry.id == entryId)
            entry.copyWith(endDate: DateTime.now())
          else
            entry,
      ];
    });
  }

  bool get _isCurrentlyWorking {
    for (final entry in _workHistory) {
      if (entry.isCurrent) return true;
    }
    return false;
  }

  List<WorkEntry> get _sortedWorkHistory {
    final entries = List<WorkEntry>.from(_workHistory);
    entries.sort((a, b) {
      if (a.isCurrent != b.isCurrent) {
        return a.isCurrent ? -1 : 1;
      }
      return b.startDate.compareTo(a.startDate);
    });
    return entries;
  }

  String? _dobToIso(String raw) => parseDobDdMmYyyy(raw);

  String? _validateDob(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.requiredField;
    if (tryParseDobDdMmYyyy(text, requireMinAge: null) == null) {
      return 'Enter a valid date (DD/MM/YYYY)';
    }
    if (tryParseDobDdMmYyyy(text) == null) {
      return 'Must be at least 18 years old';
    }
    return null;
  }

  Future<void> _pickDateOfBirth() async {
    final l10n = AppLocalizations.of(context)!;
    final latestAllowed = maxDobForMinAge();
    final parsed = tryParseDobDdMmYyyy(_dateOfBirth.text);
    final initialDate = parsed ?? DateTime(latestAllowed.year - 7);

    final picked = await showDatePicker(
      context: context,
      initialDate:
          initialDate.isAfter(latestAllowed) ? latestAllowed : initialDate,
      firstDate: DateTime(1900),
      lastDate: latestAllowed,
      helpText: l10n.dateOfBirth,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth.text = formatDobDdMmYyyy(picked);
    });
    _dobFieldKey.currentState?.validate();
  }

  void _onDobTextChanged(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    // Show age/format errors as soon as DD/MM/YYYY is complete (not only on Save).
    if (digits.length == 8 || text.isEmpty) {
      _dobFieldKey.currentState?.validate();
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_primaryTrade == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Select a primary trade')));
      return;
    }

    if (!_hasFrontImage || !_hasBackImage) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.idImagesRequired)));
      _tabController.animateTo(1);
      return;
    }

    if (_sameAsPermanent) {
      _currentAddress.copyFrom(_permanentAddress);
    }

    final years = int.tryParse(_years.text.trim()) ?? 0;
    final wage = int.tryParse(_wage.text.trim()) ?? 0;
    final permanent = _permanentAddress.toAddress();
    final present = _currentAddress.toAddress();

    setState(() => _saving = true);
    try {
      final uploads = ref.read(uploadsRepositoryProvider);

      final frontKey = _idFrontPath != null
          ? await uploads.uploadImage(
              localPath: _idFrontPath!,
              kind: 'id-front',
            )
          : _idFrontKey!;
      final backKey = _idBackPath != null
          ? await uploads.uploadImage(
              localPath: _idBackPath!,
              kind: 'id-back',
            )
          : _idBackKey!;

      final documents = <String, dynamic>{
        'primaryIdFrontUrl': frontKey,
        'primaryIdBackUrl': backKey,
        if (_idType == 'pan') 'panCardUrl': frontKey,
      };

      final body = <String, dynamic>{
        'fullName': _fullName.text.trim(),
        'gender': _gender,
        'phoneNumber': _phone.text.trim(),
        'dateOfBirth': _dobToIso(_dateOfBirth.text),
        'hasDisability': _hasDisability,
        'disabilityDetails':
            _hasDisability ? _disabilityDetails.text.trim() : '',
        'permanentAddress': permanent.toApiJson(),
        'presentSameAsPermanent': _sameAsPermanent,
        if (!_sameAsPermanent) 'presentAddress': present.toApiJson(),
        'dailyWageExpected': wage,
        'jobId': _primaryTrade!.id,
        'documents': documents,
        'workExperiences': [
          for (final entry in _workHistory)
            if (entry.companyId != null && entry.companyId!.isNotEmpty)
              {
                'companyId': entry.companyId,
                'yearsOfExperience': entry.yearsOfExperience ?? years,
              },
        ],
      };

      final notifier = ref.read(workersProvider.notifier);
      final saved = widget.isEditing
          ? await notifier.updateWorker(widget.workerId!, body)
          : await notifier.create({
              ...body,
              'idType': _idType,
              'idNumber': _idNumber.text.trim(),
            });
      if (!mounted) return;
      context.go('/worker/${saved.id}');
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiError ? e.error : e.toString();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_missingWorker) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editWorker)),
        body: Center(child: Text(l10n.workerNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.editWorker : l10n.addWorker,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.personal),
            Tab(text: l10n.documents),
            Tab(text: l10n.experience),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  _buildPersonalTab(l10n),
                  _buildDocumentsTab(l10n),
                  _buildExperienceTab(l10n),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveWorker),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: AppStyles.detailPadding,
      children: [
        TextFormField(
          controller: _fullName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l10n.fullName),
          validator: (value) => _required(value, l10n),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(labelText: l10n.mobileNumber),
          validator: (value) => _required(value, l10n),
        ),
        SizedBox(height: 12.h),
        _formDropdown(
          value: _gender,
          label: l10n.gender,
          hint: l10n.selectGender,
          options: _genders,
          optionLabel: (value) => _genderLabel(l10n, value),
          onChanged: (value) => setState(() => _gender = value),
          l10n: l10n,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          key: _dobFieldKey,
          controller: _dateOfBirth,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: const [DateSlashInputFormatter()],
          onChanged: _onDobTextChanged,
          decoration: InputDecoration(
            labelText: l10n.dateOfBirth,
            hintText: 'DD/MM/YYYY',
            suffixIcon: IconButton(
              tooltip: l10n.dateOfBirth,
              onPressed: _pickDateOfBirth,
              icon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
          validator: (value) => _validateDob(value, l10n),
        ),
        SizedBox(height: 8.h),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.hasDisability),
          value: _hasDisability,
          onChanged: (value) {
            setState(() {
              _hasDisability = value ?? false;
              if (!_hasDisability) _disabilityDetails.clear();
            });
          },
        ),
        if (_hasDisability) ...[
          SizedBox(height: 4.h),
          TextFormField(
            controller: _disabilityDetails,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.disabilityDetails,
              hintText: l10n.disabilityDetailsHint,
            ),
          ),
        ],
        if (!widget.isEditing) ...[
          SizedBox(height: 12.h),
          _formDropdown(
            value: _idType,
            label: l10n.idType,
            hint: l10n.selectIdType,
            options: _idTypes,
            optionLabel: (value) => _idTypeLabel(l10n, value),
            onChanged: _onIdTypeChanged,
            l10n: l10n,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            key: ValueKey('id-number-$_idType'),
            controller: _idNumber,
            keyboardType: _idType == 'aadhaar'
                ? TextInputType.number
                : TextInputType.text,
            textCapitalization: _idType == 'pan'
                ? TextCapitalization.characters
                : TextCapitalization.none,
            inputFormatters: [
              if (_idType == 'aadhaar') ...[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ] else if (_idType == 'pan') ...[
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(10),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text.toUpperCase(),
                    selection: newValue.selection,
                  );
                }),
              ],
            ],
            decoration: InputDecoration(
              labelText: l10n.idNumber,
              hintText: _idType == 'aadhaar'
                  ? '123456789012'
                  : (_idType == 'pan' ? 'ABCDE1234F' : null),
            ),
            validator: (value) => _validateIdNumber(value, l10n),
          ),
        ] else ...[
          SizedBox(height: 12.h),
          InputDecorator(
            decoration: InputDecoration(labelText: l10n.idType),
            child: Text(
              _idType == null ? '—' : _idTypeLabel(l10n, _idType!),
              style: textTheme.bodyLarge,
            ),
          ),
          if (_maskedIdentity != null && _maskedIdentity!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            InputDecorator(
              decoration: InputDecoration(labelText: l10n.idNumber),
              child: Text(_maskedIdentity!, style: textTheme.bodyLarge),
            ),
          ],
        ],
        SizedBox(height: 16.h),
        Text(l10n.permanentAddress, style: textTheme.titleMedium),
        SizedBox(height: 12.h),
        AddressFields(
          controllers: _permanentAddress,
          enabled: true,
          validator: (value) => _required(value, l10n),
        ),
        SizedBox(height: 20.h),
        Text(l10n.currentAddress, style: textTheme.titleMedium),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.sameAsPermanent),
          value: _sameAsPermanent,
          onChanged: _onSameAsPermanentChanged,
        ),
        AddressFields(
          controllers: _currentAddress,
          enabled: !_sameAsPermanent,
          validator: (value) => _required(value, l10n),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final selectedType = _idType;

    if (selectedType == null) {
      return ListView(
        padding: AppStyles.detailPadding,
        children: [
          Text(l10n.documents, style: textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text(
            l10n.selectIdType,
            style: textTheme.bodyLarge?.copyWith(color: muted),
          ),
        ],
      );
    }

    final docLabel = _idTypeLabel(l10n, selectedType);

    return ListView(
      padding: AppStyles.detailPadding,
      children: [
        Text(docLabel, style: textTheme.titleMedium),
        SizedBox(height: 4.h),
        Text(
          l10n.idImagesRequired,
          style: textTheme.bodySmall?.copyWith(color: muted),
        ),
        SizedBox(height: 16.h),
        _IdImageSlot(
          title: '${l10n.documentFront} · $docLabel',
          emptyLabel: l10n.addFrontImage,
          path: _idFrontPath,
          objectKey: _idFrontKey,
          onPick: () => _pickIdImage(isFront: true),
          onClear: _idFrontPath == null
              ? null
              : () => setState(() => _idFrontPath = null),
        ),
        SizedBox(height: 12.h),
        _IdImageSlot(
          title: '${l10n.documentBack} · $docLabel',
          emptyLabel: l10n.addBackImage,
          path: _idBackPath,
          objectKey: _idBackKey,
          onPick: () => _pickIdImage(isFront: false),
          onClear: _idBackPath == null
              ? null
              : () => setState(() => _idBackPath = null),
        ),
      ],
    );
  }

  Widget _buildExperienceTab(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final history = _sortedWorkHistory;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return ListView(
      padding: AppStyles.detailPadding,
      children: [
        AvailabilityChip(isAvailable: !_isCurrentlyWorking),
        SizedBox(height: 8.h),
        Text(
          l10n.availabilityHint,
          style: textTheme.bodySmall?.copyWith(color: muted),
        ),
        SizedBox(height: 16.h),
        JobSearchField(
          initial: _primaryTrade,
          onSelected: (job) => setState(() => _primaryTrade = job),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _years,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.yearsOfExperience,
          ),
          validator: (value) => _required(value, l10n),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _wage,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.dailyWageExpected,
          ),
          validator: (value) => _required(value, l10n),
        ),
        SizedBox(height: 20.h),
        Text(l10n.workHistory, style: textTheme.titleMedium),
        SizedBox(height: 8.h),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l10n.noWorkHistory),
          )
        else
          for (final entry in history) ...[
            WorkHistoryTile(
              entry: entry,
              onEndCurrent: entry.isCurrent ? () => _endWork(entry.id) : null,
            ),
            SizedBox(height: 8.h),
          ],
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _addWork,
            icon: const Icon(Icons.add),
            label: Text(l10n.addWork),
          ),
        ),
      ],
    );
  }
}

class _IdImageSlot extends ConsumerWidget {
  const _IdImageSlot({
    required this.title,
    required this.emptyLabel,
    required this.path,
    required this.onPick,
    this.objectKey,
    this.onClear,
  });

  final String title;
  final String emptyLabel;
  final String? path;
  final String? objectKey;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  bool get _hasImage =>
      (path != null && path!.isNotEmpty) ||
      (objectKey != null && objectKey!.isNotEmpty);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget preview;
    if (path != null && path!.isNotEmpty) {
      preview = Image.file(
        File(path!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: muted.withValues(alpha: 0.08),
          child: Icon(Icons.broken_image_outlined, color: muted),
        ),
      );
    } else if (objectKey != null && objectKey!.isNotEmpty) {
      preview = FutureBuilder<String>(
        future: ref.read(uploadsRepositoryProvider).signedReadUrl(objectKey!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ColoredBox(
              color: muted.withValues(alpha: 0.08),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: muted.withValues(alpha: 0.08),
              child: Icon(Icons.broken_image_outlined, color: muted),
            ),
          );
        },
      );
    } else {
      preview = const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(title),
            trailing: onClear == null
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove',
                  ),
          ),
          if (_hasImage)
            AspectRatio(aspectRatio: 16 / 10, child: preview)
          else
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(emptyLabel),
              ),
            ),
          if (_hasImage)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.refresh),
                label: Text(emptyLabel),
              ),
            ),
        ],
      ),
    );
  }
}

/// Closed state matches other inputs; open state is a narrow popup under the field.
class _CompactSelectField extends StatelessWidget {
  const _CompactSelectField({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? value;
  final String? errorText;
  final List<String> options;
  final String Function(String value) optionLabel;
  final ValueChanged<String?> onChanged;

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final selected = await showMenu<String>(
      context: context,
      color: AppColors.card,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy,
      ),
      items: [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            height: 44,
            child: Text(
              optionLabel(option),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: option == value ? FontWeight.w600 : FontWeight.w400,
                    color: option == value
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
          ),
      ],
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: value == null ? hint : optionLabel(value!),
      child: InkWell(
        onTap: () => _openMenu(context),
        borderRadius: BorderRadius.circular(AppStyles.radius),
        child: InputDecorator(
          // Empty → only floating/centered label (same as TextFormField).
          // Avoid drawing hint text in the child or it stacks on the label.
          isEmpty: value == null,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value == null ? '' : optionLabel(value!),
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
