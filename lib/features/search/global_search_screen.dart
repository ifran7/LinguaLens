import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'global_search_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final search = ref.watch(globalSearchProvider);
    final grouped = <GlobalSearchResultType, List<GlobalSearchResult>>{};
    for (final result in search.results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('search')),
        actions: [
          IconButton(
            tooltip: l.t('clearSearch'),
            onPressed: _controller.text.isEmpty
                ? null
                : () {
                    _controller.clear();
                    ref.read(globalSearchProvider.notifier).setQuery('');
                    setState(() {});
                  },
            icon: const Icon(Icons.clear_rounded),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _focusNode.unfocus,
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => ref.read(globalSearchProvider.notifier).refresh(),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  ref.read(globalSearchProvider.notifier).setQuery(value);
                  setState(() {});
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l.t('searchEverything'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: search.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              if (search.errorMessage != null)
                _SearchMessage(
                  icon: Icons.error_outline_rounded,
                  title: l.t('searchError'),
                  body: l.t('tryAgain'),
                  actionLabel: l.t('retry'),
                  onAction: () =>
                      ref.read(globalSearchProvider.notifier).refresh(),
                )
              else if (search.query.trim().isEmpty)
                _SearchMessage(
                  icon: Icons.travel_explore_rounded,
                  title: l.t('searchEverything'),
                  body: l.t('searchEverythingBody'),
                )
              else if (!search.isLoading && search.results.isEmpty)
                _SearchMessage(
                  icon: Icons.search_off_rounded,
                  title: l.t('noResultsFound'),
                  body: l.t('tryDifferentSearch'),
                )
              else
                ...GlobalSearchResultType.values
                    .where((type) => grouped[type]?.isNotEmpty == true)
                    .map(
                      (type) => _SearchGroup(
                        type: type,
                        results: grouped[type]!,
                        onTap: (result) => context.push(result.route),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchGroup extends StatelessWidget {
  const _SearchGroup({
    required this.type,
    required this.results,
    required this.onTap,
  });

  final GlobalSearchResultType type;
  final List<GlobalSearchResult> results;
  final ValueChanged<GlobalSearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (title, icon, color) = switch (type) {
      GlobalSearchResultType.student => (
        l.t('students'),
        Icons.people_alt_rounded,
        AppColors.primary,
      ),
      GlobalSearchResultType.batch => (
        l.t('batches'),
        Icons.groups_rounded,
        AppColors.secondary,
      ),
      GlobalSearchResultType.lesson => (
        l.t('lessons'),
        Icons.menu_book_rounded,
        AppColors.success,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Text(
                '${results.length}',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        ...results.map(
          (result) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              minVerticalPadding: 12,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon, size: 20),
              ),
              title: Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                result.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onTap(result),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
        child: Column(
          children: [
            Icon(icon, size: 56, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
