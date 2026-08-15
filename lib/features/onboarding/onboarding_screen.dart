import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.isLanguagePage = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool isLanguagePage;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<OnboardingPageData> _pages(BuildContext context) {
    final l = context.l10n;
    return [
      OnboardingPageData(
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
        title: l.t('onboarding1Title'),
        body: l.t('onboarding1Body'),
      ),
      OnboardingPageData(
        icon: Icons.calendar_month_rounded,
        color: AppColors.secondary,
        title: l.t('onboarding2Title'),
        body: l.t('onboarding2Body'),
      ),
      OnboardingPageData(
        icon: Icons.auto_graph_rounded,
        color: AppColors.success,
        title: l.t('onboarding3Title'),
        body: l.t('onboarding3Body'),
      ),
      OnboardingPageData(
        icon: Icons.cloud_off_rounded,
        color: AppColors.warning,
        title: l.t('onboarding4Title'),
        body: l.t('onboarding4Body'),
      ),
      OnboardingPageData(
        icon: Icons.translate_rounded,
        color: const Color(0xFF7C3AED),
        title: l.t('onboarding5Title'),
        body: l.t('onboarding5Body'),
        isLanguagePage: true,
      ),
    ];
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) context.go('/dashboard');
  }

  void _goNext(int length) {
    if (_page == length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final current = pages[_page];
    final isLast = _page == pages.length - 1;
    final l = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      tooltip: l.t('back'),
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: Text(l.t('skip'))),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) => _OnboardingPageView(
                    page: pages[index],
                    onLanguageSelected: (locale) => ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(locale),
                  ),
                ),
              ),
              OnboardingIndicator(
                count: pages.length,
                currentIndex: _page,
                color: current.color,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => _goNext(pages.length),
                  icon: Icon(
                    isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  ),
                  label: Text(isLast ? l.t('getStarted') : l.t('next')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    required this.count,
    required this.currentIndex,
    required this.color,
    super.key,
  });

  final int count;
  final int currentIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${context.l10n.t('onboardingProgress')} ${currentIndex + 1}/$count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: index == currentIndex ? 28 : 8,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? color
                  : color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.onLanguageSelected,
  });

  final OnboardingPageData page;
  final ValueChanged<Locale> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: page.color.withValues(alpha: 0.09),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: page.color.withValues(alpha: 0.12),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                color: page.color,
                borderRadius: BorderRadius.circular(38),
              ),
              child: Icon(page.icon, color: Colors.white, size: 62),
            ),
          ),
        ),
        const SizedBox(height: 44),
        Text(
          page.title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          page.body,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
        if (page.isLanguagePage) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _LanguageCard(
                  label: context.l10n.t('english'),
                  sample: 'English',
                  locale: const Locale('en'),
                  selected:
                      Localizations.localeOf(context).languageCode == 'en',
                  onTap: () => onLanguageSelected(const Locale('en')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageCard(
                  label: context.l10n.t('bangla'),
                  sample: 'বাংলা',
                  locale: const Locale('bn'),
                  selected:
                      Localizations.localeOf(context).languageCode == 'bn',
                  onTap: () => onLanguageSelected(const Locale('bn')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.label,
    required this.sample,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sample;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Theme.of(context).dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(sample, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
