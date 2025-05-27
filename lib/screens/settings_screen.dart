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
        error = AppLocalizations.of(context)!.planLoadError;
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
                    user?.email ?? AppLocalizations.of(context)!.unknownUser,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.changeLanguage,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.language),
                    label: Text(
                      localeProvider.locale.languageCode == 'ru'
                          ? AppLocalizations.of(context)!.switchToEnglish
                          : AppLocalizations.of(context)!.switchToRussian,
                    ),
                    onPressed: () {
                      localeProvider.toggleLocale();
                    },
                  ),

                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.myPlan,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  if (plan != null)
                    Text(AppLocalizations.of(context)!.currentPlan(_getPlanLabel(plan!))),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: Text(AppLocalizations.of(context)!.upgradePlan),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.underDevelopment),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(AppLocalizations.of(context)!.logOut),
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
        return AppLocalizations.of(context)!.premium;
      case 'free':
      default:
        return AppLocalizations.of(context)!.free;
    }
  }
}
