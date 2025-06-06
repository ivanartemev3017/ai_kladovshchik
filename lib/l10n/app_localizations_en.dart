// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Warehouse';

  @override
  String get goToStorages => 'Go to storages';

  @override
  String get myProfile => 'My Profile';

  @override
  String get zones => 'Zones';

  @override
  String get noZones => 'No zones';

  @override
  String get addZone => 'Add zone';

  @override
  String get editZone => 'Edit zone';

  @override
  String get zoneName => 'Zone name';

  @override
  String get created => 'Created';

  @override
  String get deleteZone => 'Delete zone?';

  @override
  String get zoneDeleteWarning => 'All items in the zone will also be deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get delete => 'Delete';

  @override
  String get editStorage => 'Edit storage';

  @override
  String get addStorage => 'Add storage';

  @override
  String get storageName => 'Storage name';

  @override
  String get deleteStorageTitle => 'Delete storage?';

  @override
  String get deleteStorageMessage => 'All zones and items inside will be deleted.';

  @override
  String get createdAt => 'Created';

  @override
  String get itemsInZone => 'Items in zone';

  @override
  String get sortBy => 'Sort by';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get quantity => 'Quantity';

  @override
  String get added => 'Added';

  @override
  String get editItem => 'Edit item';

  @override
  String get addItem => 'Add item';

  @override
  String get itemName => 'Item name';

  @override
  String get itemQuantity => 'Item quantity';

  @override
  String get itemCost => 'Item cost (optional)';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get zoneStatsTitle => 'Zone statistics';

  @override
  String zoneStatsBody(Object totalItems, Object totalQuantity, Object totalCost) {
    return 'Total unique items: $totalItems\nTotal quantity: $totalQuantity\nTotal cost: $totalCost₸';
  }

  @override
  String get close => 'Close';

  @override
  String get logOut => 'Log out';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToRussian => 'Switch to Russian';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get myPlan => 'My plan';

  @override
  String currentPlan(Object plan) {
    return 'Current plan: $plan';
  }

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get planLoadError => 'Error loading plan';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get stats => 'Statistics';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get quantityAsc => 'Quantity ↑';

  @override
  String get quantityDesc => 'Quantity ↓';

  @override
  String get noItems => 'No items';

  @override
  String get noStorages => 'No storages';

  @override
  String get underDevelopment => 'This feature is under development';

  @override
  String get makeBackup => 'Create backup';

  @override
  String get premiumOnly => 'This feature is available in the premium plan';

  @override
  String get backupCreated => 'Backup exported to console';

  @override
  String get backupUploaded => 'Backup uploaded to the cloud';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupRestored => '✅ Backup restored';

  @override
  String get restoreFailed => '❌ Restore failed';

  @override
  String get restoreFromList => '🔁 Restore from backup list';

  @override
  String get chooseBackup => 'Choose a backup';

  @override
  String get noBackupsFound => '❌ No backups found';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get feedback => 'Send Feedback';

  @override
  String get feedbackError => 'Unable to open email app';
}
