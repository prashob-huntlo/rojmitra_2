import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../../../core/errors/api_error.dart';
import '../data/catalog_repository.dart';
import '../models/catalog_job.dart';

class _JobSuggestion {
  const _JobSuggestion.match(this.job) : createName = null;
  const _JobSuggestion.create(this.createName) : job = null;

  final CatalogJob? job;
  final String? createName;

  bool get isCreate => createName != null;

  String get label {
    if (isCreate) return 'Add "$createName"';
    return job!.name;
  }
}

/// Search-as-you-type main work field with an "Add …" option when there is no exact match.
/// Partner-added jobs are created as pending for admin verification.
class JobSearchField extends ConsumerStatefulWidget {
  const JobSearchField({
    super.key,
    required this.onSelected,
    this.initial,
    this.label,
  });

  final ValueChanged<CatalogJob?> onSelected;
  final CatalogJob? initial;
  final String? label;

  @override
  ConsumerState<JobSearchField> createState() => _JobSearchFieldState();
}

class _JobSearchFieldState extends ConsumerState<JobSearchField> {
  CatalogJob? _selected;
  bool _creating = false;
  String _query = '';
  Timer? _debounce;
  Completer<List<_JobSuggestion>>? _inflight;
  List<_JobSuggestion> _lastOptions = const [];

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

  Future<List<_JobSuggestion>> _search(String raw) async {
    final query = raw.trim();
    _query = query;
    if (query.isEmpty) {
      _lastOptions = const [];
      return const [];
    }

    if (_inflight != null && !_inflight!.isCompleted) {
      _inflight!.complete(_lastOptions);
    }

    final completer = Completer<List<_JobSuggestion>>();
    _inflight = completer;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final matches = await ref.read(catalogRepositoryProvider).searchJobs(query);
        if (!mounted || _query != query) {
          if (!completer.isCompleted) completer.complete(_lastOptions);
          return;
        }
        final options = <_JobSuggestion>[
          for (final job in matches) _JobSuggestion.match(job),
        ];
        final hasExact = matches.any(
          (j) => j.name.toLowerCase() == query.toLowerCase(),
        );
        if (!hasExact) {
          options.add(_JobSuggestion.create(query));
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

  Future<void> _handleSelected(_JobSuggestion suggestion) async {
    if (suggestion.isCreate) {
      setState(() => _creating = true);
      try {
        final created =
            await ref.read(catalogRepositoryProvider).addJob(suggestion.createName!);
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

    setState(() => _selected = suggestion.job);
    widget.onSelected(suggestion.job);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Autocomplete<_JobSuggestion>(
      displayStringForOption: (option) =>
          option.isCreate ? (option.createName ?? '') : option.job!.name,
      optionsBuilder: (value) => _search(value.text),
      onSelected: _handleSelected,
      initialValue: _selected == null ? null : TextEditingValue(text: _selected!.name),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_creating,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: widget.label ?? l10n.primaryTrade,
            hintText: 'Search or add a trade',
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
          validator: (_) {
            if (_selected == null) return l10n.requiredField;
            return null;
          },
          onChanged: (text) {
            if (_selected != null && text.trim() != _selected!.name) {
              setState(() => _selected = null);
              widget.onSelected(null);
            }
          },
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }
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
                    leading: option.isCreate
                        ? const Icon(Icons.add_circle_outline)
                        : null,
                    title: Text(option.label),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
