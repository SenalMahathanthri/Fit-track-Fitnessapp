// lib/core/routes/app_pages.dart
import 'package:get/get.dart';
import '../../features/auth/splash/splash_screen.dart';
import '../../features/auth/onboarding/onboarding_screen.dart';
import '../../features/auth/welcome/welcome_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/signup/signup_screen.dart';
import '../../features/auth/forgot_password/forgot_password_screen.dart';
import '../../features/auth/email_verification/email_verification_screen.dart';
import '../../features/dashboard/home/dashboard_screen.dart';
import '../../features/main_tab/main_tab_view.dart';
import '../../features/coach/coach_dashboard_screen.dart';
import '../../features/coach/client_details_screen.dart';
import '../../features/coach/plan_review_screen.dart';

/// Routes names as constants for easy access
class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String workoutTracker = '/workout-tracker';
  static const String mealPlanner = '/meal-planner';
  static const String progressTracker = '/progress-tracker';
  static const String settings = '/settings';
  static const String adminDashboard = '/admin-dashboard'; // Add this route
  static const String coachDashboard = '/coach-dashboard';
  static const String clientDetails = '/client-details';
  static const String planApproval = '/plan-approval';
}

/// App pages configuration for GetX routing
class AppPages {
  static final List<GetPage> pages = [
    // Splash and onboarding
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    // Authentication
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.emailVerification,
      page: () => const EmailVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    // Main app screens
    GetPage(
      name: Routes.main,
      page: () => const MainTabView(),
      transition: Transition.fadeIn,
    ),
    // GetPage(
    //   name: Routes.progressTracker,
    //   page: () => const ProgressTrackingScreen(),
    //   transition: Transition.rightToLeft,
    // ),
    // Admin screen
    GetPage(
      name: Routes.adminDashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.coachDashboard,
      page: () => const CoachDashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.clientDetails,
      page: () => const ClientDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.planApproval,
      page: () => const PlanReviewScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
