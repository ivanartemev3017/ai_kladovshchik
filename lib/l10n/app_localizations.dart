import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Warehouse'**
  String get appTitle;

  /// No description provided for @goToStorages.
  ///
  /// In en, this message translates to:
  /// **'Go to storages'**
  String get goToStorages;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @zones.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zones;

  /// No description provided for @noZones.
  ///
  /// In en, this message translates to:
  /// **'No zones'**
  String get noZones;

  /// No description provided for @addZone.
  ///
  /// In en, this message translates to:
  /// **'Add zone'**
  String get addZone;

  /// No description provided for @editZone.
  ///
  /// In en, this message translates to:
  /// **'Edit zone'**
  String get editZone;

  /// No description provided for @zoneName.
  ///
  /// In en, this message translates to:
  /// **'Zone name'**
  String get zoneName;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @deleteZone.
  ///
  /// In en, this message translates to:
  /// **'Delete zone?'**
  String get deleteZone;

  /// No description provided for @zoneDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'All items in the zone will also be deleted.'**
  String get zoneDeleteWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editStorage.
  ///
  /// In en, this message translates to:
  /// **'Edit storage'**
  String get editStorage;

  /// No description provided for @addStorage.
  ///
  /// In en, this message translates to:
  /// **'Add storage'**
  String get addStorage;

  /// No description provided for @storageName.
  ///
  /// In en, this message translates to:
  /// **'Storage name'**
  String get storageName;

  /// No description provided for @deleteStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete storage?'**
  String get deleteStorageTitle;

  /// No description provided for @deleteStorageMessage.
  ///
  /// In en, this message translates to:
  /// **'All zones and items inside will be deleted.'**
  String get deleteStorageMessage;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @itemsInZone.
  ///
  /// In en, this message translates to:
  /// **'Items in zone'**
  String get itemsInZone;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @itemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Item quantity'**
  String get itemQuantity;

  /// No description provided for @itemCost.
  ///
  /// In en, this message translates to:
  /// **'Item cost (optional)'**
  String get itemCost;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @zoneStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone statistics'**
  String get zoneStatsTitle;

  /// Zone statistics
  ///
  /// In en, this message translates to:
  /// **'Total unique items: {totalItems}\nTotal quantity: {totalQuantity}\nTotal cost: {totalCost}₸'**
  String zoneStatsBody(Object totalItems, Object totalQuantity, Object totalCost);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToRussian.
  ///
  /// In en, this message translates to:
  /// **'Switch to Russian'**
  String get switchToRussian;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @myPlan.
  ///
  /// In en, this message translates to:
  /// **'My plan'**
  String get myPlan;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan: {plan}'**
  String currentPlan(Object plan);

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get upgradePlan;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @planLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading plan'**
  String get planLoadError;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @quantityAsc.
  ///
  /// In en, this message translates to:
  /// **'Quantity ↑'**
  String get quantityAsc;

  /// No description provided for @quantityDesc.
  ///
  /// In en, this message translates to:
  /// **'Quantity ↓'**
  String get quantityDesc;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @noStorages.
  ///
  /// In en, this message translates to:
  /// **'No storages'**
  String get noStorages;

  /// No description provided for @underDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development'**
  String get underDevelopment;

  /// No description provided for @makeBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get makeBackup;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'This feature is available in the premium plan'**
  String get premiumOnly;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup exported to console'**
  String get backupCreated;

  /// No description provided for @backupUploaded.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded to the cloud'**
  String get backupUploaded;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'✅ Backup restored'**
  String get backupRestored;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Restore failed'**
  String get restoreFailed;

  /// No description provided for @restoreFromList.
  ///
  /// In en, this message translates to:
  /// **'🔁 Restore from backup list'**
  String get restoreFromList;

  /// No description provided for @chooseBackup.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup'**
  String get chooseBackup;

  /// No description provided for @noBackupsFound.
  ///
  /// In en, this message translates to:
  /// **'❌ No backups found'**
  String get noBackupsFound;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedback;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email app'**
  String get feedbackError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
