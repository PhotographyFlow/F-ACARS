// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get yourApiKey => 'Your api key (don\'t share this!)';

  @override
  String get apiKeyWrong => 'Ensure enter the right api key.';

  @override
  String get yourVaUrl => 'Your VA URL (without\'/\' on end)';

  @override
  String get invalidUrl => 'invalid url';

  @override
  String get delete => 'Delete';

  @override
  String get submit => 'Submit';

  @override
  String get save => 'Save';

  @override
  String get testConnection => 'Test connection';

  @override
  String get test => 'Test';

  @override
  String get testOK => '✓ OK';

  @override
  String get eCheckVA => 'ERROR, check your VA URL';

  @override
  String get e401 => 'ERROR 401 Unauthorized, check your API key and VA URL';

  @override
  String get e404 => 'ERROR 404 Not Found, check your VA URL';

  @override
  String get e400 => 'ERROR 400 Validation Errors, contact developer';

  @override
  String get eInternet => 'ERROR, check your internet connection and VA URL setting';

  @override
  String get language => 'Language';

  @override
  String get connectionType => 'Connection Type';

  @override
  String get connectionTypeTip => 'FSUIPC: For FSX,P3D,MSFS2020/2024\nXPUIPC: For X-Plane 11/12\nPlease make sure FSUIPC/XPUIPC is installed';

  @override
  String get weightUnit => 'Weight Unit';

  @override
  String get clear => 'Clear';

  @override
  String get refresh => 'Refresh';

  @override
  String get startFlight => 'Start flight';

  @override
  String get airline => 'Airline';

  @override
  String get flightNumber => 'Flight number';

  @override
  String get dep => 'DEP';

  @override
  String get arr => 'ARR';

  @override
  String get aircraftType => 'Aircraft type';

  @override
  String get aircraftIcaoCode => 'Aircraft ICAO code';

  @override
  String get aircraftName => 'Name';

  @override
  String get registration => 'Registration';

  @override
  String get blockFuel => 'Block fuel';

  @override
  String get noFares => 'No fares available';

  @override
  String get route => 'Route';

  @override
  String get prefiling => 'Prefiling pirep, please wait...';

  @override
  String get prefilingError => 'There is an error occurred while prefiling. Please check your settings and internet connection.';

  @override
  String get error => 'Error';

  @override
  String get noBidsFoundTitle => 'No bids found :(';

  @override
  String get noBidsFound => 'Couldn\'t find any bids. Check your settings and internet connection or add one bid at your VA website.';

  @override
  String get back => 'Back';

  @override
  String get quit => 'Quit';

  @override
  String get fares => 'Fares';

  @override
  String get code => 'Code';

  @override
  String get count => 'Count';
}
