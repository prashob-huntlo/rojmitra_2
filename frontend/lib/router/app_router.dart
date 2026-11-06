import 'package:go_router/go_router.dart';

import '../auth/forgot_password_page.dart';
import '../auth/login_page.dart';
import '../auth/pending_approval_page.dart';
import '../auth/rejected_page.dart';
import '../auth/signup_page.dart';
import '../pages/auth/channel_selection_page.dart';
import '../workers/worker_detail_page.dart';
import '../workers/worker_form_page.dart';
import '../workers/company_detail_page.dart';
import '../home/authentication_details_page.dart';
import '../home/workers_page.dart';
import '../home/home_tab.dart';
import '../home/legal_document_page.dart';
import '../home/main_shell.dart';
import '../home/personal_details_page.dart';
import '../home/preferences_page.dart';
import '../home/profile_tab.dart';
import '../l10n/language_selection_page.dart';
import '../splash_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/choose-language',
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // Partner onboarding: pick channel → channel-specific signup → pending approval.
      GoRoute(
        path: '/signup',
        builder: (context, state) => const ChannelSelectionPage(),
      ),
      GoRoute(
        path: '/signup/details',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/pending',
        builder: (context, state) => const PendingApprovalPage(),
      ),
      GoRoute(
        path: '/rejected',
        builder: (context, state) => const RejectedPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return ForgotPasswordPage(initialPhone: phone);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workers',
                builder: (context, state) => const WorkersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileTab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/workers-list',
        builder: (context, state) => const WorkersPage(showAppBar: true),
      ),
      GoRoute(
        path: '/worker/new',
        builder: (context, state) => const WorkerFormPage(),
      ),
      GoRoute(
        path: '/worker/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return WorkerFormPage(
            workerId: id,
            initialTabIndex: tab,
          );
        },
      ),
      GoRoute(
        path: '/worker/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return WorkerDetailPage(workerId: id);
        },
      ),
      GoRoute(
        path: '/company/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CompanyDetailPage(companyId: id);
        },
      ),
      GoRoute(
        path: '/profile/authentication',
        builder: (context, state) => const AuthenticationDetailsPage(),
      ),
      GoRoute(
        path: '/profile/personal',
        builder: (context, state) => const PersonalDetailsPage(),
      ),
      GoRoute(
        path: '/profile/preferences',
        builder: (context, state) => const PreferencesPage(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsAndConditionsPage(),
      ),
    ],
  );
}
