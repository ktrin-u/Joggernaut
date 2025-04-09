import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/game_screens/create_character_page.dart';
import 'package:flutter_application_1/screens/game_screens/game_dashboard_page.dart';
import 'package:flutter_application_1/screens/game_screens/leaderboards_page.dart';
import 'package:flutter_application_1/screens/game_screens/my_characters_page.dart';
import 'package:flutter_application_1/screens/game_screens/view_character_page.dart';
import 'package:flutter_application_1/screens/settings_screens/account_settings_page.dart';
import 'package:flutter_application_1/screens/admin_screens/admin_page.dart';
import 'package:flutter_application_1/screens/admin_screens/admin_user_profiles.dart';
import 'package:flutter_application_1/screens/social_screens/notifications_page.dart';
import 'package:flutter_application_1/screens/social_screens/add_friend_page.dart';
import 'package:flutter_application_1/screens/social_screens/social_user_profiles.dart';
import 'package:flutter_application_1/screens/workout_screens/challenges.dart';
import 'package:flutter_application_1/screens/workout_screens/sessions.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/screens/landing_page.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/screens/profile_screens/profile_page.dart';
import 'package:flutter_application_1/screens/workout_screens/workout_page.dart';
import 'package:flutter_application_1/screens/game_screens/game_page.dart';
import 'package:flutter_application_1/screens/social_screens/social_page.dart';
import 'package:flutter_application_1/screens/settings_screens/settings_page.dart';
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
          routes: [
            GoRoute(path: '/workout', builder: (context, state) => WorkoutPage()),
            GoRoute(path: '/workout/sessions', builder: (context, state) => WorkoutSessionPage()),
            GoRoute(path: '/workout/challenges', builder: (context, state) => WorkoutChallengesPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/game', builder: (context, state) => GameDashboardPage()),
            GoRoute(path: '/game/play', builder: (context, state) => GamePage()),
            GoRoute(path: '/game/leaderboards', builder: (context, state) => LeaderboardsPage()),
            GoRoute(path: '/game/create-character', builder: (context, state) => CreateCharacterPage()),
            GoRoute(path: '/game/my-characters', builder: (context, state) => MyCharactersPage()),
            GoRoute(path: '/game/view-character/:characterid', builder: (context, state) {
              final String? characterid = state.pathParameters['characterid'];
              return ViewCharacterPage(characterid: characterid!);
            }),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (context, state) => ProfilePage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/social', builder: (context, state) => SocialPage()),
            GoRoute(path: '/social/notifications', builder: (context, state) => NotificationsPage()),
            GoRoute(path: '/social/profile/:userid/:accountname', builder: (context, state) {
              final String? friendID = state.pathParameters['userid'];
              final String? friendName = state.pathParameters['accountname'];
              return SocialUserProfilePage(userId: friendID!, userName: friendName!);
            }),
            GoRoute(path: '/social/add', builder: (context, state) => AddFriendPage())
          ],
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

