import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/change_password_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';

import '../../features/manage_user/presentation/manage_user_page.dart';

import '../../features/notification/presentation/notification_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/setting/presentation/setting_page.dart';
import '../../features/splash/presentation/splash_page.dart';

import '../../features/ticket/presentation/create_ticket_page.dart';
import '../../features/ticket/presentation/ticket_list_page.dart';

import '../../features/tracking/presentation/tracking_page.dart';

class AppRoutes {
  static const String splash = '/';

  static const String login = '/login';

  static const String register = '/register';

  static const String changePassword = '/change-password';

  static const String forgotPassword = '/forgot-password';

  static const String dashboard = '/dashboard';

  static const String ticketList = '/ticket-list';

  static const String createTicket = '/create-ticket';

  static const String tracking = '/tracking';

  static const String notification = '/notification';

  static const String profile = '/profile';

  static const String settings = '/settings';

  static const String manageUser = '/manage-user';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),

    login: (context) => const LoginPage(),

    register: (context) => const RegisterPage(),

    changePassword: (context) => const ChangePasswordPage(),

    forgotPassword: (context) => const ForgotPasswordPage(),

    dashboard: (context) => const DashboardPage(),

    ticketList: (context) => const TicketListPage(),

    createTicket: (context) => const CreateTicketPage(),

    tracking: (context) => const TrackingPage(),

    notification: (context) => const NotificationPage(),

    profile: (context) => const ProfilePage(),

    settings: (context) => const SettingPage(),

    manageUser: (context) => const ManageUserPage(),
  };
}