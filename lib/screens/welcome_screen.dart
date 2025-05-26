// screens/welcome_screen.dart

import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';
import '../services/google_auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'AI Кладовщик',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Войти через Google'),
                  onPressed: () async {
                    final user = await GoogleAuthService().signInWithGoogle();
                    if (user != null) {
                      await Provider.of<LocaleProvider>(context,
                              listen: false)
                          .loadLocaleFromFirestore();
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ошибка входа через Google'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/email-auth');
                  },
                  child: const Text('Войти или зарегистрироваться по Email'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
