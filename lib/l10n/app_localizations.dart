import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// API Key input box at settings page
  ///
  /// In en, this message translates to:
  /// **'Your api key (don\'t share this!)'**
  String get yourApiKey;

  /// Wrong api key message at settings page
  ///
  /// In en, this message translates to:
  /// **'Ensure enter the right api key.'**
  String get apiKeyWrong;

  /// VA URL input box at settings page
  ///
  /// In en, this message translates to:
  /// **'Your VA URL (without\'/\' on end)'**
  String get yourVaUrl;

  /// Invalid VA URL message at settings page
  ///
  /// In en, this message translates to:
  /// **'invalid url'**
  String get invalidUrl;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Test connection in settings page
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// Test button
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// Test OK message
  ///
  /// In en, this message translates to:
  /// **'✓ OK'**
  String get testOK;

  /// test connection error
  ///
  /// In en, this message translates to:
  /// **'ERROR, check your VA URL'**
  String get eCheckVA;

  /// test connection error
  ///
  /// In en, this message translates to:
  /// **'ERROR 401 Unauthorized, check your API key and VA URL'**
  String get e401;

  /// test connection error
  ///
  /// In en, this message translates to:
  /// **'ERROR 404 Not Found, check your VA URL'**
  String get e404;

  /// test connection error
  ///
  /// In en, this message translates to:
  /// **'ERROR 400 Validation Errors, contact developer'**
  String get e400;

  /// test connection error
  ///
  /// In en, this message translates to:
  /// **'ERROR, check your internet connection and VA URL setting'**
  String get eInternet;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Connection type setting
  ///
  /// In en, this message translates to:
  /// **'Connection Type'**
  String get connectionType;

  /// Connection type setting toop tip
  ///
  /// In en, this message translates to:
  /// **'FSUIPC: For FSX,P3D,MSFS2020/2024\nXPUIPC: For X-Plane 11/12\nPlease make sure FSUIPC/XPUIPC is installed'**
  String get connectionTypeTip;

  /// Weight unit setting
  ///
  /// In en, this message translates to:
  /// **'Weight Unit'**
  String get weightUnit;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Start flight button
  ///
  /// In en, this message translates to:
  /// **'Start flight'**
  String get startFlight;

  /// Airline label
  ///
  /// In en, this message translates to:
  /// **'Airline'**
  String get airline;

  /// Flight number label
  ///
  /// In en, this message translates to:
  /// **'Flight number'**
  String get flightNumber;

  /// DEP label
  ///
  /// In en, this message translates to:
  /// **'DEP'**
  String get dep;

  /// ARR label
  ///
  /// In en, this message translates to:
  /// **'ARR'**
  String get arr;

  /// Aircraft type label
  ///
  /// In en, this message translates to:
  /// **'Aircraft type'**
  String get aircraftType;

  /// Aircraft ICAO code label
  ///
  /// In en, this message translates to:
  /// **'Aircraft ICAO code'**
  String get aircraftIcaoCode;

  /// aircraft Name label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get aircraftName;

  /// Registration label
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registration;

  /// Block fuel label
  ///
  /// In en, this message translates to:
  /// **'Block fuel'**
  String get blockFuel;

  /// No fares available reminder
  ///
  /// In en, this message translates to:
  /// **'No fares available'**
  String get noFares;

  /// Route label
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// Prefiling pirep reminder
  ///
  /// In en, this message translates to:
  /// **'Prefiling pirep, please wait...'**
  String get prefiling;

  /// Prefiling error pop up window
  ///
  /// In en, this message translates to:
  /// **'There is an error occurred while prefiling. Please check your settings and internet connection.'**
  String get prefilingError;

  /// Error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No bids found info bar title
  ///
  /// In en, this message translates to:
  /// **'No bids found :('**
  String get noBidsFoundTitle;

  /// No bids found info bar message
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find any bids. Check your settings and internet connection or add one bid at your VA website.'**
  String get noBidsFound;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Quit button
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// Fare table title
  ///
  /// In en, this message translates to:
  /// **'Fares'**
  String get fares;

  /// Fare table fare code
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Fare table fare count
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
