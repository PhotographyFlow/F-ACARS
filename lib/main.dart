import 'package:f_acars/l10n/app_localizations.dart';
import 'package:f_acars/navigation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'l10n/l10n.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    title: "F-ACARS",
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: Size(588, 450),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 0;
  Locale? _selectedLocale;
  final apiKeyController = TextEditingController();
  final _storage = FlutterSecureStorage();
  bool _initialized = false;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  void onLocaleChanged(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLang();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
      if (kDebugMode) {
        print('rebuild!');
      }
    });
  }

  Future<void> _loadLang() async {
    final settings = await _storage.read(key: 'settings');
    if (settings != null) {
      final jsonSettings = jsonDecode(settings);
      final localeCode = jsonSettings['locale'];
      if (localeCode != null) {
        _selectedLocale = Locale(localeCode);
        onLocaleChanged(_selectedLocale!);
      }
    }
  }

  Future<void> initPlatformState() async {
    try {
      _deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
      _initialized = true;
    } on Exception {
      _deviceData["buildNumber"] = 0;
    }
    if (!mounted) return;
    setState(() {});
  }

  void setEffect(WindowEffect effect, bool dark, context) {
    Window.setEffect(effect: effect, dark: dark);
  }

  WindowEffect effect = WindowEffect.disabled;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (!_initialized) ? initPlatformState() : null,
      builder: (context, snapshot) {
        if (kDebugMode) {
          print('FutureBuilder snapshot: $snapshot');
        }
        if (_initialized) {
          // Set mica effect if Windows 11
          if (_deviceData['buildNumber'] >= 22000) {
            setEffect(WindowEffect.mica, true, context);
            effect = WindowEffect.mica;
          } else {
            effect = WindowEffect.disabled;
          }

          return FluentApp(
            locale: _selectedLocale,
            localizationsDelegates: [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            supportedLocales: L10n.all,
            title: 'F-ACARS',

            theme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.blue,

              // Let navigation be transparent if win11 to work with mica effect:
              navigationPaneTheme: effect == WindowEffect.mica
                  ? NavigationPaneThemeData(backgroundColor: Colors.transparent)
                  : NavigationPaneThemeData(backgroundColor: null),
            ),

            home: Navigation(
              onLocaleChanged: onLocaleChanged,
              buildNumber: _deviceData['buildNumber'],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    'userName': data.userName,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'buildNumber': data.buildNumber,
    'platformId': data.platformId,
    'csdVersion': data.csdVersion,
    'servicePackMajor': data.servicePackMajor,
    'servicePackMinor': data.servicePackMinor,
    'suitMask': data.suitMask,
    'productType': data.productType,
    'reserved': data.reserved,
    'buildLab': data.buildLab,
    'buildLabEx': data.buildLabEx,
    'digitalProductId': data.digitalProductId,
    'displayVersion': data.displayVersion,
    'editionId': data.editionId,
    'installDate': data.installDate,
    'productId': data.productId,
    'productName': data.productName,
    'registeredOwner': data.registeredOwner,
    'releaseId': data.releaseId,
    'deviceId': data.deviceId,
  };
}
