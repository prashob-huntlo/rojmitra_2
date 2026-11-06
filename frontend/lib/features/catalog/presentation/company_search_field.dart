import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../../../core/errors/api_error.dart';
import '../data/catalog_repository.dart';
import '../models/catalog_company.dart';

class _CompanySuggestion {
  const _CompanySuggestion.match(this.company) : createName = null;
  const _CompanySuggestion.create(this.createName) : company = null;

  final CatalogCompany? company;
  final String? createName;

  bool get isCreate => createName != null;

  String get label {
    if (isCreate) return 'Add "$createName"';
    return company!.name;
  }
}

/// Search-as-you-type company field with an "Add …" option when there is no exact match.
class CompanySearchField extends ConsumerStatefulWidget {
  const CompanySearchField({
    super.key,
    required this.onSelected,
    this.initial,
  });

  final ValueChanged<CatalogCompany?> onSelected;
  final CatalogCompany? initial;

  @override
  ConsumerState<CompanySearchField> createState() => _CompanySearchFieldState();
}

class _CompanySearchFieldState extends ConsumerState<CompanySearchField> {
  CatalogCompany? _selected;
  bool _creating = false;
  String _query = '';
  Timer? _debounce;
  Completer<List<_CompanySuggestion>>? _inflight;
  List<_CompanySuggestion> _lastOptions = const [];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is ApiError ? error.error : error.toString();
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<List<_CompanySuggestion>> _search(String raw) async {
    final query = raw.trim();
    _query = query;
    if (query.isEmpty) {
      _lastOptions = const [];
      return const [];
    }

    if (_inflight != null && !_inflight!.isCompleted) {
      _inflight!.complete(_lastOptions);
    }

    final completer = Completer<List<_CompanySuggestion>>();
    _inflight = completer;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final matches =
            await ref.read(catalogRepositoryProvider).searchCompanies(query);
        if (!mounted || _query != query) {
          if (!completer.isCompleted) completer.complete(_lastOptions);
          return;
        }
        final options = <_CompanySuggestion>[
          for (final company in matches) _CompanySuggestion.match(company),
        ];
        final hasExact = matches.any(
          (c) => c.name.toLowerCase() == query.toLowerCase(),
        );
        if (!hasExact) {
          options.add(_CompanySuggestion.create(query));
        }
        _lastOptions = options;
        if (!completer.isCompleted) completer.complete(options);
      } catch (e) {
        if (!completer.isCompleted) completer.complete(_lastOptions);
        if (mounted) _showError(e);
      }
    });

    return completer.future;
  }

  Future<void> _handleSelected(_CompanySuggestion suggestion) async {
    if (suggestion.isCreate) {
      setState(() => _creating = true);
      try {
        final created = await ref
            .read(catalogRepositoryProvider)
            .addCompany(suggestion.createName!);
        if (!mounted) return;
        setState(() {
          _selected = created;
          _creating = false;
        });
        widget.onSelected(created);
      } catch (e) {
        if (!mounted) return;
        setState(() => _creating = false);
        _showError(e);
        widget.onSelected(null);
      }
      return;
    }

    setState(() => _selected = suggestion.company);
    widget.onSelected(suggestion.company);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Autocomplete<_CompanySuggestion>(
          displayStringForOption: (option) =>
              option.isCreate ? (option.createName ?? '') : option.company!.name,
          optionsBuilder: (value) => _search(value.text),
          onSelected: _handleSelected,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !_creating,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l10n.company,
                hintText: 'Search or add a company',
                prefixIcon: const Icon(Icons.business_outlined),
                suffixIcon: _creating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_selected != null
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null),
              ),
              onChanged: (text) {
                if (_selected != null && text.trim() != _selected!.name) {
                  setState(() => _selected = null);
                  widget.onSelected(null);
                }
              },
              onSubmitted: (_) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220, maxWidth: 360),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          option.isCreate
                              ? Icons.add_business_outlined
                              : Icons.business_outlined,
                        ),
                        title: Text(option.label),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
