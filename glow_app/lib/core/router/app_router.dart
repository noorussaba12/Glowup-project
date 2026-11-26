import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/gender_selection_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/scan/scan_instructions_screen.dart';
import '../../features/scan/scanner_screen.dart';
import '../../features/analysis/analysis_loading_screen.dart';
import '../../features/analysis/results_screen.dart';
import '../../features/chat/chat_questionnaire_screen.dart';
import '../../features/report/report_screen.dart';
import '../../features/plan/priority_selection_screen.dart';
import '../../features/plan/my_plan_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/nutriflow/screens/nutriflow_home_screen.dart';
import '../../features/nutriflow/screens/nutriflow_setup_screen.dart';
import '../../features/nutriflow/screens/nutriflow_plan_screen.dart';
import '../../features/nutriflow/screens/nutriflow_meal_details_screen.dart';
import '../../features/nutriflow/screens/nutriflow_tracker_screen.dart';
import '../../features/nutriflow/screens/nutriflow_schedule_screen.dart';
import '../../features/nutriflow/screens/nutriflow_calendar_screen.dart';
import '../../features/nutriflow/screens/nutriflow_dashboard_screen.dart';
import '../../features/nutriflow/models/meal_model.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/models/plan_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/gender',
      builder: (context, state) => const GenderSelectionScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/instructions',
      builder: (context, state) => const ScanInstructionsScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imageFile = extra['imageFile'] as File?;
        return AnalysisLoadingScreen(imageFile: imageFile);
      },
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final scanResult = extra['scanResult'] as ScanResult?;
        final imageFile = extra['imageFile'] as File?;
        return ResultsScreen(
          scanResult: scanResult,
          imageFile: imageFile,
        );
      },
    ),
    GoRoute(
      path: '/questionnaire',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final scanResult = extra['scanResult'] as ScanResult?;
        final imageFile = extra['imageFile'] as File?;
        return ChatQuestionnaireScreen(
          scanResult: scanResult,
          imageFile: imageFile,
        );
      },
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final scanResult = extra['scanResult'] as ScanResult?;
        final questionnaire = extra['questionnaire'] as Map<String, dynamic>?;
        final reportData = extra['reportData'] as Map<String, dynamic>?;
        final imageFile = extra['imageFile'] as File?;
        return ReportScreen(
          scanResult: scanResult,
          questionnaire: questionnaire,
          reportData: reportData,
          imageFile: imageFile,
        );
      },
    ),
    GoRoute(
      path: '/priorities',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final scanResult = extra['scanResult'] as ScanResult?;
        final questionnaire = extra['questionnaire'] as Map<String, dynamic>?;
        final reportData = extra['reportData'] as Map<String, dynamic>?;
        final imageFile = extra['imageFile'] as File?;
        return PrioritySelectionScreen(
          scanResult: scanResult,
          questionnaire: questionnaire,
          reportData: reportData,
          imageFile: imageFile,
        );
      },
    ),
    GoRoute(
      path: '/plan',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final plan = extra['plan'] as GlowPlan?;
        return MyPlanScreen(plan: plan);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/nutriflow',
      builder: (context, state) => const NutriflowHomeScreen(),
    ),
    GoRoute(
      path: '/nutriflow/setup',
      builder: (context, state) => const NutriflowSetupScreen(),
    ),
    GoRoute(
      path: '/nutriflow/plan',
      builder: (context, state) => const NutriflowPlanScreen(),
    ),
    GoRoute(
      path: '/nutriflow/meal-details',
      builder: (context, state) {
        final meal = state.extra as MealModel?;
        return NutriflowMealDetailsScreen(meal: meal);
      },
    ),
    GoRoute(
      path: '/nutriflow/tracker',
      builder: (context, state) => const NutriflowTrackerScreen(),
    ),
    GoRoute(
      path: '/nutriflow/schedule',
      builder: (context, state) => const NutriflowScheduleScreen(),
    ),
    GoRoute(
      path: '/nutriflow/calendar',
      builder: (context, state) => const NutriflowCalendarScreen(),
    ),
    GoRoute(
      path: '/nutriflow/dashboard',
      builder: (context, state) => const NutriflowDashboardScreen(),
    ),
  ],
);
