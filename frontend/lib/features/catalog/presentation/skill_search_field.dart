import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../../../core/errors/api_error.dart';
import '../data/catalog_repository.dart';
import '../models/catalog_skill.dart';

class _SkillSuggestion {
  const _SkillSuggestion.match(this.skill) : createName = null;
  const _SkillSuggestion.create(this.createName) : skill = null;

  final CatalogSkill? skill;
  final String? createName;

  bool get isCreate => createName != null;

  String get label {
    if (isCreate) return 'Add "$createName"';
    return skill!.name;
  }
}

/// Search-as-you-type skill field with an "Add …" option when there is no exact match.
class SkillSearchField extends ConsumerStatefulWidget {
  const SkillSearchField({
    super.key,
    required this.onSelected,
    this.initial,
    this.label,
  });

  final ValueChanged<CatalogSkill?> onSelected;
  final CatalogSkill? initial;
  final String? label;

  @override
  ConsumerState<SkillSearchField> createState() => _SkillSearchFieldState();
}

class _SkillSearchFieldState extends ConsumerState<SkillSearchField> {
  CatalogSkill? _selected;
  bool _creating = false;
  String _query = '';
  Timer? _debounce;
  Completer<List<_SkillSuggestion>>? _inflight;
  List<_SkillSuggestion> _lastOptions = const [];

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

  Future<List<_SkillSuggestion>> _search(String raw) async {
    final query = raw.trim();
    _query = query;
    if (query.isEmpty) {
      _lastOptions = const [];
      return const [];
    }

    if (_inflight != null && !_inflight!.isCompleted) {
      _inflight!.complete(_lastOptions);
    }

    final completer = Completer<List<_SkillSuggestion>>();
    _inflight = completer;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final matches = await ref.read(catalogRepositoryProvider).searchSkills(query);
        if (!mounted || _query != query) {
          if (!completer.isCompleted) completer.complete(_lastOptions);
          return;
        }
        final options = <_SkillSuggestion>[
          for (final skill in matches) _SkillSuggestion.match(skill),
        ];
        final hasExact = matches.any(
          (s) => s.name.toLowerCase() == query.toLowerCase(),
        );
        if (!hasExact) {
          options.add(_SkillSuggestion.create(query));
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

  Future<void> _handleSelected(_SkillSuggestion suggestion) async {
    if (suggestion.isCreate) {
      setState(() => _creating = true);
      try {
        final created =
            await ref.read(catalogRepositoryProvider).addSkill(suggestion.createName!);
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

    setState(() => _selected = suggestion.skill);
    widget.onSelected(suggestion.skill);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Autocomplete<_SkillSuggestion>(
      displayStringForOption: (option) =>
          option.isCreate ? (option.createName ?? '') : option.skill!.name,
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
