import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../core/ui/date_slash_formatter.dart';
import '../features/catalog/models/catalog_company.dart';
import '../features/catalog/presentation/company_search_field.dart';
import 'worker.dart';

Future<WorkEntry?> showAddWorkSheet(BuildContext context) {
  return showModalBottomSheet<WorkEntry>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _AddWorkSheet(),
  );
}

class _AddWorkSheet extends ConsumerStatefulWidget {
  const _AddWorkSheet();

  @override
  ConsumerState<_AddWorkSheet> createState() => _AddWorkSheetState();
}

class _AddWorkSheetState extends ConsumerState<_AddWorkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _trade = TextEditingController();
  late final TextEditingController _fromDate;
  late final TextEditingController _toDate;

  CatalogCompany? _selectedCompany;
  bool _stillWorking = true;

  @override
  void initState() {
    super.initState();
    // Empty on open — pre-filling today made it feel like nothing to enter.
    _fromDate = TextEditingController();
    _toDate = TextEditingController();
  }

  @override
  void dispose() {
    _trade.dispose();
    _fromDate.dispose();
    _toDate.dispose();
    super.dispose();
  }

  String? _validateWorkDate(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.requiredField;
    if (tryParseDobDdMmYyyy(text, requireMinAge: null) == null) {
      return 'Enter a valid date (DD/MM/YYYY)';
    }
    return null;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final parsed = tryParseDobDdMmYyyy(controller.text, requireMinAge: null);
    final initial = parsed ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(1980),
      lastDate: today,
      helpText: l10n.fromDate,
    );
    if (picked == null || !mounted) return;
    setState(() {
      controller.text = formatDobDdMmYyyy(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompany == null) return;

    final start = tryParseDobDdMmYyyy(_fromDate.text, requireMinAge: null);
    if (start == null) return;

    DateTime? end;
    if (!_stillWorking) {
      end = tryParseDobDdMmYyyy(_toDate.text, requireMinAge: null);
      if (end == null) return;
      if (end.isBefore(start)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('To date must be on or after From')),
          );
        return;
      }
    }

    final entry = WorkEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: _selectedCompany!.id,
      companyName: _selectedCompany!.name,
      trade: _trade.text.trim().isEmpty ? null : _trade.text.trim(),
      startDate: start,
      endDate: _stillWorking ? null : end,
    );

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.addWork, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              CompanySearchField(
                onSelected: (company) {
                  setState(() => _selectedCompany = company);
                },
              ),
              if (_selectedCompany == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.requiredField,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _trade,
                decoration: InputDecoration(labelText: l10n.primaryTrade),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fromDate,
                keyboardType: TextInputType.number,
                inputFormatters: const [DateSlashInputFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.fromDate,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    tooltip: l10n.fromDate,
                    onPressed: () => _pickDate(_fromDate),
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                validator: (value) => _validateWorkDate(value, l10n),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.stillWorking),
                value: _stillWorking,
                onChanged: (value) {
                  setState(() {
                    _stillWorking = value;
                    if (value) _toDate.clear();
                  });
                },
              ),
              if (!_stillWorking)
                TextFormField(
                  controller: _toDate,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [DateSlashInputFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.toDate,
                    hintText: 'DD/MM/YYYY',
                    suffixIcon: IconButton(
                      tooltip: l10n.toDate,
                      onPressed: () => _pickDate(_toDate),
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  validator: (value) => _validateWorkDate(value, l10n),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.addWork),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
