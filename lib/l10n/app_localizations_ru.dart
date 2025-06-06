// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AI Кладовщик';

  @override
  String get goToStorages => 'Перейти к складам';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get zones => 'Зоны';

  @override
  String get noZones => 'Нет зон';

  @override
  String get addZone => 'Добавить зону';

  @override
  String get editZone => 'Редактировать зону';

  @override
  String get zoneName => 'Название зоны';

  @override
  String get created => 'Создана';

  @override
  String get deleteZone => 'Удалить зону?';

  @override
  String get zoneDeleteWarning => 'Все предметы в зоне тоже будут удалены.';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get settings => 'Настройки';

  @override
  String get delete => 'Удалить';

  @override
  String get editStorage => 'Редактировать склад';

  @override
  String get addStorage => 'Добавить склад';

  @override
  String get storageName => 'Название склада';

  @override
  String get deleteStorageTitle => 'Удалить склад?';

  @override
  String get deleteStorageMessage => 'Все зоны и вещи внутри будут удалены.';

  @override
  String get createdAt => 'Создан';

  @override
  String get itemsInZone => 'Предметы в зоне';

  @override
  String get sortBy => 'Сортировка по';

  @override
  String get searchByName => 'Поиск по названию';

  @override
  String get quantity => 'Количество';

  @override
  String get added => 'Добавлено';

  @override
  String get editItem => 'Редактировать предмет';

  @override
  String get addItem => 'Добавить предмет';

  @override
  String get itemName => 'Название предмета';

  @override
  String get itemQuantity => 'Количество предмета';

  @override
  String get itemCost => 'Стоимость предмета';

  @override
  String get choosePhoto => 'Выбрать фото';

  @override
  String get zoneStatsTitle => 'Статистика по зоне';

  @override
  String zoneStatsBody(Object totalItems, Object totalQuantity, Object totalCost) {
    return 'Всего разных вещей: $totalItems\nСуммарное количество: $totalQuantity\nСуммарная стоимость: $totalCost';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get logOut => 'Выйти';

  @override
  String get switchToEnglish => 'Переключиться на английский';

  @override
  String get switchToRussian => 'Переключиться на русский';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get myPlan => 'Мой план';

  @override
  String currentPlan(Object plan) {
    return 'Текущий план: $plan';
  }

  @override
  String get upgradePlan => 'Обновить план';

  @override
  String get free => 'Бесплатно';

  @override
  String get premium => 'Премиум';

  @override
  String get planLoadError => 'Ошибка при загрузке плана';

  @override
  String get unknownUser => 'Неизвестный пользователь';

  @override
  String get stats => 'Статистика';

  @override
  String get newestFirst => 'Новые сверху';

  @override
  String get oldestFirst => 'Старые сверху';

  @override
  String get quantityAsc => 'Количество ↑';

  @override
  String get quantityDesc => 'Количество ↓';

  @override
  String get noItems => 'Нет вещей';

  @override
  String get noStorages => 'Нет складов';

  @override
  String get underDevelopment => 'Функция в разработке';

  @override
  String get makeBackup => 'Сделать резервную копию';

  @override
  String get premiumOnly => 'Функция доступна только в премиум-версии';

  @override
  String get backupCreated => 'Резервная копия выведена в консоль';

  @override
  String get backupUploaded => 'Резервная копия загружена в облако';

  @override
  String get restoreBackup => 'Восстановить копию';

  @override
  String get backupRestored => '✅ Резервная копия восстановлена';

  @override
  String get restoreFailed => '❌ Ошибка при восстановлении';

  @override
  String get restoreFromList => '🔁 Восстановить из списка резервных копий';

  @override
  String get chooseBackup => 'Выберите резервную копию';

  @override
  String get noBackupsFound => '❌ Резервные копии не найдены';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get exportToExcel => 'Экспорт в Excel';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get feedbackError => 'Не удалось открыть почтовое приложение';
}
