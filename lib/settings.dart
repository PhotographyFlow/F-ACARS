import 'dart:async';
import 'package:f_acars/l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as ui;
import 'package:flutter/foundation.dart';
import 'web_comm.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'l10n/locale_names.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SettingsPage({super.key, required this.onLocaleChanged});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final apiKeyController = TextEditingController();
  final vaUrlController = TextEditingController();
  String? apiKeyValidationError = '';
  String? vaUrlValidationError = '';
  Text? testConnnectionError;
  bool _isTesting = false;
  final _storage = FlutterSecureStorage();
  Timer? _timer;
  AnimationController? _animationController;
  Future? _testFuture;
  int weightUnit = 0; //0=lbs, 1=kg
  int connectionType = 0; //0=MS, 1=XPlane

  @override
  void initState() {
    super.initState();
    _selectedLocale = Locale('en');
    vaUrlController.text = '';
    _loadSettings();
    vaUrlController.addListener(() {
      _validateVaUrl(vaUrlController.text);
    });
    apiKeyController.addListener(() {
      _validateApiKey(apiKeyController.text);
    });

    _timer?.cancel();
    _animationController?.removeListener(() {});
    _animationController?.dispose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.removeListener(() {});
    _animationController?.dispose();
    _testFuture?.then((_) => null).catchError((_) => null);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.read(key: 'settings');
    if (settings != null) {
      final jsonSettings = jsonDecode(settings);
      vaUrlController.text = jsonSettings['vaUrl'] ?? '';
      apiKeyController.text = jsonSettings['apiKey'] ?? '';
      final localeCode = jsonSettings['locale'];
      setState(() {
        weightUnit = jsonSettings['weightUnit'] ?? 0;
        connectionType = jsonSettings['connectionType'] ?? 0;
      });
      if (localeCode != null) {
        _selectedLocale = Locale(localeCode);
        _changeLocale(_selectedLocale);
      }
    }
  }

  Future<void> _saveSettings(String key, dynamic value) async {
    final settings = await _storage.read(key: 'settings');
    if (settings != null) {
      final jsonSettings = jsonDecode(settings);
      jsonSettings[key] = value;
      await _storage.write(key: 'settings', value: jsonEncode(jsonSettings));
    } else {
      await _storage.write(key: 'settings', value: jsonEncode({key: value}));
    }
  }

  void _validateApiKey(String text) {
    if (text.length != 20) {
      setState(
        () => apiKeyValidationError = AppLocalizations.of(context)!.apiKeyWrong,
      );
    } else {
      setState(() => apiKeyValidationError = null);
    }
  }

  void _validateVaUrl(String text) {
    setState(() => vaUrlValidationError = null);
    try {
      final uri = Uri.parse(text);
      if (uri.scheme.isEmpty || uri.host.isEmpty || uri.path.endsWith('/')) {
        setState(
          () => vaUrlValidationError = AppLocalizations.of(context)!.invalidUrl,
        );
      }
    } on FormatException {
      setState(
        () => vaUrlValidationError = AppLocalizations.of(context)!.invalidUrl,
      );
    }
  }

  Locale? _selectedLocale;

  void _changeLocale(Locale? locale) {
    if (locale != null) {
      widget.onLocaleChanged.call(locale);
    }
  }

  //Settings page
  @override
  Widget build(BuildContext context) {
    FluentThemeData(brightness: Brightness.dark, accentColor: Colors.blue);

    return ScaffoldPage.scrollable(
      header: PageHeader(title: Text(AppLocalizations.of(context)!.settings)),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expander(
              header: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  spacing: 20,
                  children: [
                    Icon(FluentIcons.settings),
                    Column(
                      spacing: 1,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credentials'),
                        Text(
                          'For app to communicate with phpVMS api',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[90],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(0),
              content: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.yourVaUrl),
                        PasswordFormBox(
                          controller: vaUrlController,
                          revealMode: PasswordRevealMode.visible,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          placeholder: 'https://vms.example.com',
                          validator: (text) => vaUrlValidationError,
                        ),
                        Row(
                          children: [
                            Button(
                              onPressed: vaUrlValidationError == null
                                  ? () {
                                      _saveSettings(
                                        'vaUrl',
                                        vaUrlController.text,
                                      ).then((_) {});
                                    }
                                  : null,
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                            SizedBox(width: 10),
                            //clear VA URL button
                            Button(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.red,
                                ),
                              ),
                              onPressed: () async {
                                await _storage.delete(key: 'vaUrl');
                                vaUrlController.clear();
                                await _saveSettings(
                                  'vaUrl',
                                  vaUrlController.text,
                                );
                                setState(() {
                                  vaUrlValidationError = '';
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Api key input box
                        Text(AppLocalizations.of(context)!.yourApiKey),
                        PasswordFormBox(
                          controller: apiKeyController,
                          revealMode: PasswordRevealMode.peekAlways,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) => apiKeyValidationError,
                        ),
                        Row(
                          children: [
                            //Save api key button
                            Button(
                              onPressed: apiKeyValidationError == null
                                  ? () {
                                      _saveSettings(
                                        'apiKey',
                                        apiKeyController.text,
                                      );
                                    }
                                  : null,
                              child: Text(AppLocalizations.of(context)!.save),
                            ),
                            SizedBox(width: 10),
                            //clear api key button
                            Button(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  Colors.red,
                                ),
                              ),
                              onPressed: () async {
                                await _storage.delete(key: 'apiKey');
                                apiKeyController.clear();
                                await _saveSettings(
                                  'apiKey',
                                  apiKeyController.text,
                                );
                                setState(() {
                                  apiKeyValidationError = '';
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //test connection
            SettingsCard(
              child: Row(
                children: [
                  Icon(FluentIcons.plug_disconnected),
                  SizedBox(width: 20),
                  Column(
                    spacing: 1,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.testConnection),
                      Text(
                        'To test your connection',
                        style: TextStyle(fontSize: 12, color: Colors.grey[90]),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  _isTesting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: ProgressRing(
                            strokeWidth: 3,
                            backgroundColor: Colors.transparent,
                          ),
                        )
                      : SizedBox(
                          width: 20,
                          height: 20,
                          child: ProgressRing(
                            strokeWidth: 3,
                            value: 0,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                  Spacer(),
                  testConnnectionError ?? Text(''),
                  SizedBox(width: 10),
                  Button(
                    onPressed: () {
                      if (!_isTesting) {
                        setState(() {
                          _isTesting = true;
                        });
                        _testFuture = WebComm()
                            .testConnection(
                              vaUrlController,
                              apiKeyController,
                              apiKeyValidationError,
                              vaUrlValidationError,
                              null,
                              context,
                            )
                            .then((result) {
                              if (kDebugMode) {
                                print('Result: $result');
                              }
                              setState(() {
                                testConnnectionError = result;
                                _isTesting = false;
                              });
                            });
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.test),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //select weight unit
            SettingsCard(
              child: Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: Icon(ui.FluentIcons.ruler_48_regular),
                  ),
                  SizedBox(width: 20),
                  Text(AppLocalizations.of(context)!.weightUnit),
                ],
              ),
            ),
            Text(AppLocalizations.of(context)!.weightUnit),
            SizedBox(height: 10),

            //select weight unit combo box
            ComboBox(
              value: weightUnit,
              onChanged: (int? value) {
                setState(() {
                  weightUnit = value!;
                  _saveSettings('weightUnit', value);
                });
              },
              items: [
                ComboBoxItem(value: 0, child: Text('lbs')),
                ComboBoxItem(value: 1, child: Text('kg')),
              ],
            ),

            //select connection simulator
            SizedBox(height: 20),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.connectionType),
                SizedBox(width: 7),
                Padding(
                  padding: const EdgeInsets.only(top: 2.5),
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.connectionTypeTip,
                    displayHorizontally: true,
                    useMousePosition: false,
                    style: const TooltipThemeData(preferBelow: true),
                    child: const Icon((FluentIcons.info), size: 11),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ComboBox(
              value: connectionType,
              onChanged: (int? value) {
                setState(() {
                  connectionType = value!;
                  _saveSettings('connectionType', value);
                });
              },
              items: [
                ComboBoxItem(value: 0, child: Text('FSUIPC')),
                ComboBoxItem(value: 1, child: Text('XPUIPC')),
              ],
            ),

            //select language
            SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.language),

            //select language combo box
            SizedBox(height: 10),
            ComboBox(
              value: _selectedLocale,
              onChanged: (Locale? locale) {
                setState(() {
                  _selectedLocale = locale;
                  _changeLocale(locale!);
                  _saveSettings('locale', locale.languageCode);
                });
              },
              items: AppLocalizations.supportedLocales
                  .map(
                    (locale) => ComboBoxItem(
                      value: locale,
                      child: Text(LocaleNames.names[locale.languageCode]!),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72.0),
      decoration: ShapeDecoration(
        color: FluentTheme.of(context).resources.cardBackgroundFillColorDefault,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: FluentTheme.of(context).resources.cardStrokeColorDefault,
          ),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(6.0),
            bottom: Radius.circular(6.0),
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }
}
