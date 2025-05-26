import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import '../widgets/background_wrapper.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // ⬅️ это обязательный импорт



class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Добро пожаловать'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Войти через Google'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () async {
                    final user = await GoogleAuthService().signInWithGoogle();
                    if (user != null) {
                      print('Успешный вход: ${user.email}');
					  
					  await Provider.of<LocaleProvider>(context, listen: false).loadLocaleFromFirestore();
					  
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Вход отменён или произошла ошибка'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/email-auth');
                  },
                  child: const Text('Войти по Email'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text('Забыли пароль?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
