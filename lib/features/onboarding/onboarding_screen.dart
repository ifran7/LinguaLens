import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_OnboardingPage> _pages(BuildContext context) {
    final l = context.l10n;
    return [
      _OnboardingPage(
        Icons.people_alt_rounded,
        AppColors.primary,
        l.t('onboarding1Title'),
        l.t('onboarding1Body'),
      ),
      _OnboardingPage(
        Icons.calendar_month_rounded,
        AppColors.secondary,
        l.t('onboarding2Title'),
        l.t('onboarding2Body'),
      ),
      _OnboardingPage(
        Icons.tune_rounded,
        AppColors.success,
        l.t('onboarding3Title'),
        l.t('onboarding3Body'),
      ),
    ];
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final current = pages[_page];
    final isLast = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.t('appName'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(context.l10n.t('skip')),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) =>
                      _OnboardingPageView(page: pages[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: index == _page ? 28 : 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? current.color
                          : current.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast
                            ? context.l10n.t('getStarted')
                            : context.l10n.t('next'),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage(this.icon, this.color, this.title, this.body);
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 232,
          height: 232,
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
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: page.color,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(page.icon, color: Colors.white, size: 64),
            ),
          ),
        ),
        const SizedBox(height: 56),
        Text(
          page.title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          page.body,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
