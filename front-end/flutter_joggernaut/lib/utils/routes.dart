import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/account_settings_page.dart';
import 'package:flutter_application_1/screens/admin_page.dart';
import 'package:flutter_application_1/screens/admin_user_profiles.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screens/landing_page.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:flutter_application_1/screens/workout_page.dart';
import 'package:flutter_application_1/screens/game_page.dart';
import 'package:flutter_application_1/screens/social_page.dart';
import 'package:flutter_application_1/screens/settings_page.dart';
import 'package:flutter_application_1/widgets/navigation_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    String? token = await AuthService().getAccessToken();
    if (token == null && state.fullPath != '/') {
      return '/';
    }
    if (token != null && state.fullPath == '/') {
      return '/home'; 
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: "landingpage",
      builder: (context, state) => LandingPage(),
    ),

    GoRoute(
      path: '/home',
      name: "homepage",
      builder: (context, state) => HomePage(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PopScope(
          canPop: false,
           onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go('/home');
              }
            }
          },
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: CustomNavigationBar(navigationShell)
          )
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/workout', builder: (context, state) => WorkoutPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/game', builder: (context, state) => GamePage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (context, state) => ProfilePage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/social', builder: (context, state) => SocialPage())],
        ),
        StatefulShellBranch(
           routes: [
            GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
            GoRoute(path: '/settings/account', builder: (context, state) => AccountSettingsPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/admin', builder: (context, state) => AdminPage()),
            GoRoute(path: '/admin/users', builder: (context, state) => AdminUserProfilesPage())
          ],
        ),
      ]
    )
  ]
);

