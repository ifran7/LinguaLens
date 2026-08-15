import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/student_entity.dart';
import '../../providers/student_provider.dart';
import '../widgets/student_card.dart';
import '../widgets/student_filters_bar.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(studentsListProvider.notifier).loadStudents(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      Future.delayed(
        const Duration(milliseconds: 120),
        _searchFocus.requestFocus,
      );
    } else {
      _searchController.clear();
      ref.read(studentsListProvider.notifier).searchStudents('');
    }
  }

  Future<void> _showStudentActions(StudentEntity student) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.t('editStudent')),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(
                student.isActive
                    ? Icons.archive_outlined
                    : Icons.unarchive_outlined,
              ),
              title: Text(
                student.isActive
                    ? context.l10n.t('archiveStudent')
                    : context.l10n.t('restoreStudent'),
              ),
              onTap: () => Navigator.pop(
                context,
                student.isActive ? 'archive' : 'restore',
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: Text(context.l10n.t('deleteStudent')),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        context.push('/students/edit/${student.id}');
      case 'archive':
        await _archive(student);
      case 'restore':
        await ref
            .read(studentsListProvider.notifier)
            .restoreStudent(student.id);
        if (mounted) _success(context.l10n.t('studentRestored'));
      case 'delete':
        await _delete(student);
    }
  }

  Future<void> _archive(StudentEntity student) async {
    await ref.read(studentsListProvider.notifier).archiveStudent(student.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.t('studentArchived')),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref
              .read(studentsListProvider.notifier)
              .restoreStudent(student.id),
        ),
      ),
    );
  }

  Future<void> _delete(StudentEntity student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('deleteStudent')),
        content: Text(context.l10n.t('deleteStudentConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.t('deleteStudent')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(studentsListProvider.notifier).deleteStudent(student.id);
      if (mounted) _success(context.l10n.t('studentDeleted'));
    }
  }

  void _success(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsListProvider);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l.t('students')),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            tooltip: l.t('searchStudents'),
            icon: Icon(
              _searchOpen ? Icons.close_rounded : Icons.search_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(studentsListProvider.notifier).loadStudents(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          children: [
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: _searchOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: ref
                      .read(studentsListProvider.notifier)
                      .searchStudents,
                  decoration: InputDecoration(
                    hintText: l.t('searchStudentsHint'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(studentsListProvider.notifier)
                            .searchStudents('');
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
            StudentFiltersBar(
              state: state,
              onChanged: ref.read(studentsListProvider.notifier).setFilter,
            ),
            const SizedBox(height: 20),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              _ErrorState(
                message: state.errorMessage!,
                onRetry: () =>
                    ref.read(studentsListProvider.notifier).loadStudents(),
              )
            else if (state.allStudents.isEmpty)
              _EmptyStudents(onPressed: () => context.push('/students/add'))
            else if (state.filteredStudents.isEmpty)
              _NoResults()
            else
              ...state.filteredStudents.map(
                (student) => StudentCard(
                  student: student,
                  onTap: () => context.push('/students/${student.id}'),
                  onLongPress: () => _showStudentActions(student),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/students/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.t('addStudent')),
      ),
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            Icons.person_add_alt_1_rounded,
            size: 34,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.t('noStudentsYet'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.t('tapToAddFirstStudent'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.t('addFirstStudent')),
        ),
      ],
    ),
  );
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 110),
    child: Column(
      children: [
        Icon(Icons.search_off_rounded, size: 52, color: AppColors.muted),
        const SizedBox(height: 16),
        Text(
          context.l10n.t('noResultsFound'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.t('tryDifferentSearch'),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 100),
    child: Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 52,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(context.l10n.t('retry')),
        ),
      ],
    ),
  );
}
