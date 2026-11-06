import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/ui/app_logo.dart';
import 'features/auth/presentation/auth_notifier.dart';
import 'l10n/locale_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _delayDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Short brand beat; don't hold people for a full 2s after the native splash.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      _delayDone = true;
      _goNext();
    });
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated || !_delayDone) return;

    final localeState = ref.read(localeProvider);
    if (!localeState.isReady) return;

    _navigated = true;

    // Language is optional (Preferences / login picker). First open → login or home.
    try {
      await ref.read(authNotifierProvider.notifier).checkAuthStatus();
    } catch (_) {
      // Network blip with a saved token → still land on login rather than hang.
      if (!mounted) return;
      context.go('/login');
      return;
    }

    if (!mounted) return;

    switch (ref.read(authNotifierProvider)) {
      case Authenticated():
        context.go('/home');
      case AwaitingApproval():
        context.go('/pending');
      case Rejected():
        context.go('/rejected');
      default:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppLocaleState>(localeProvider, (previous, next) {
      if (next.isReady) {
        _goNext();
      }
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AppLogo.hero(width: 280),
      ),
    );
  }
}
