import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? plan;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserPlan();
  }

  Future<void> _loadUserPlan() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      setState(() {
        plan = data?['plan'] ?? 'free';
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка при загрузке плана';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'Неизвестный пользователь',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 32),
                  const Text('🌐 Сменить язык',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.language),
                    label: Text(localeProvider.locale.languageCode == 'ru'
                        ? 'Switch to English'
                        : 'Переключить на Русский'),
                    onPressed: () {
                      localeProvider.toggleLocale();
                    },
                  ),

                  const SizedBox(height: 32),
                  const Text('💼 Мой план',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  if (plan != null) Text('Текущий план: ${_getPlanLabel(plan!)}'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Обновить план'),
                    onPressed: () {
                      // Здесь позже будет реальный экран оплаты
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
      ),
    );
  }

  String _getPlanLabel(String planCode) {
    switch (planCode) {
      case 'premium':
        return 'Премиум';
      case 'free':
      default:
        return 'Бесплатный';
    }
  }
}
