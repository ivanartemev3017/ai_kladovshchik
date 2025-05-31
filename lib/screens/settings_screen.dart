import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/backup_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? plan;
  bool loading = true;
  bool backupLoading = false;
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

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  if (plan != null)
                    Text(AppLocalizations.of(context)!
                        .currentPlan(_getPlanLabel(plan!))),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: Text(AppLocalizations.of(context)!.upgradePlan),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.underDevelopment),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.backup),
                    label: backupLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(AppLocalizations.of(context)!.makeBackup),
                    onPressed: backupLoading
                        ? null
                        : () async {
                            setState(() => backupLoading = true);
                            try {
                              final backupService = BackupService();
                              final success =
                                  await backupService.exportAndUploadBackup();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? AppLocalizations.of(context)!
                                          .backupUploaded
                                      : AppLocalizations.of(context)!
                                          .premiumOnly),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('❌ Ошибка: $e')),
                              );
                            } finally {
                              setState(() => backupLoading = false);
                            }
                          },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.restore),
                    label: Text(AppLocalizations.of(context)!.restoreBackup),
                    onPressed: () async {
                      setState(() => backupLoading = true);

                      try {
                        final backupService = BackupService();
                        final success =
                            await backupService.restoreBackupFromFirebase();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? AppLocalizations.of(context)!.backupRestored
                                : AppLocalizations.of(context)!.restoreFailed),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => backupLoading = false);
                        }
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label:
                        Text(AppLocalizations.of(context)!.restoreFromList),
                    onPressed: _showBackupRestoreDialog,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(AppLocalizations.of(context)!.logOut),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  Future<void> _showBackupRestoreDialog() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final listRef = FirebaseStorage.instance.ref().child('backups/$uid');
    final result = await listRef.listAll();

    if (result.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noBackupsFound)),
      );
      return;
    }

    final selectedFilename = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.chooseBackup),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final item = result.items[index];
                final filename = item.name;

                return ListTile(
                  title: Text(filename),
                  onTap: () {
                    Navigator.of(context).pop(filename);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedFilename != null) {
      setState(() => backupLoading = true);
      final backupService = BackupService();
      final success =
          await backupService.restoreBackupFromFile(selectedFilename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? AppLocalizations.of(context)!.backupRestored
              : AppLocalizations.of(context)!.restoreFailed),
        ));
        setState(() => backupLoading = false);
      }
    }
  }
}
