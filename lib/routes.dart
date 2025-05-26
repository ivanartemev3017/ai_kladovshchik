// routes.dart

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/email_auth_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/storage_list_screen.dart';
import 'screens/add_storage_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const WelcomeScreen(),
  '/email-auth': (context) => const EmailAuthScreen(isLogin: true),
  '/forgot-password': (context) => ForgotPasswordScreen(),
  '/home': (context) => const HomeScreen(),
  '/storages': (context) => const StorageListScreen(),
  '/add-storage': (context) => const AddStorageScreen(),
};
