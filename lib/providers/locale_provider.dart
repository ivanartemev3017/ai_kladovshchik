import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  /// Установить язык вручную и сохранить в Firestore
  void setLocale(Locale locale) {
    if (!['ru', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    _saveLanguageToFirestore(locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    final newLocale = _locale.languageCode == 'ru'
        ? const Locale('en')
        : const Locale('ru');
    setLocale(newLocale);
  }

  /// Загружаем язык из Firestore при запуске
  Future<void> loadLocaleFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final lang = doc.data()?['language'];
      if (lang != null && ['ru', 'en'].contains(lang)) {
        _locale = Locale(lang);
        notifyListeners();
      }
    } catch (e) {
      // Игнорируем, оставим язык по умолчанию
    }
  }

  /// Сохраняем язык пользователя в Firestore
  Future<void> _saveLanguageToFirestore(String lang) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'language': lang,
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
