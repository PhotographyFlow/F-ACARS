import 'package:f_acars/web_comm.dart';
import 'package:flutter/foundation.dart';
import 'package:f_acars/l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'Flight/start_flight_loading.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomePage extends StatefulWidget {
  final int buildNumber;
  const HomePage({super.key, required this.buildNumber});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> fares = [
    /*
    {
      "id": 1,
      "code": "Y",
      "name": "Economy",
      "capacity": 180,
      "cost": null,
      "count": null,
      "price": 100,
      "type": 0,
      "notes": null,
      "active": true,
    },

    {
      "id": 2,
      "code": "Cargo",
      "name": "Cargo",
      "capacity": 9440,
      "cost": null,
      "count": null,
      "price": 15,
      "type": 1,
      "notes": null,
      "active": true,
    },

    //these are for test only
    */
  ];

  Timer? _timer;
  AnimationController? _animationController;
  Future? _testFuture;

  final _storage = const FlutterSecureStorage();
  final apiKeyController = TextEditingController();
  final vaUrlController = TextEditingController();
  int weightUnit = 0; // 0=lbs, 1=kg
  bool _isLoading = false;

  String? airlineIcao;
  String? airlineIata;
  String? flightNumber;
  String? depAirport;
  String? arrAirport;
  String? aircraftType;
  String? aircraftIcao;
  String? aircraftName;
  String? aircraftReg;

  String? flightID;
  late int airlineID;
  late int aircraftID;

  late num plannedDistance;
  late int plannedFlightTime;

  late int loadFactor;
  late int loadFactorVariance;

  final blockFuelController = TextEditingController();
  final routeController = TextEditingController();

  bool bidIsLoaded = false;

  @override
  void initState() {
    super.initState();
    blockFuelController.text = '0';
    _loadSettings();

    routeController.addListener(() {
      setState(() {}); // Update the UI
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
    apiKeyController.removeListener(() {});
    vaUrlController.removeListener(() {});
    apiKeyController.dispose();
    vaUrlController.dispose();
    blockFuelController.dispose();
    routeController.dispose();

    super.dispose();
  }

  void generateRandomCounts(
    List<dynamic> fares,
    int loadFactor,
    int loadFactorVariance,
  ) {
    if (kDebugMode) {
      print(loadFactor);
      print(loadFactorVariance);
    }
    for (var fare in fares) {
      int minCount =
          (fare["capacity"] * ((loadFactor - loadFactorVariance) / 100))
              .toInt();
      if (minCount < 0) {
        minCount = 0;
      }
      int maxCount =
          (fare["capacity"] * ((loadFactor + loadFactorVariance) / 100))
              .toInt();
      if (maxCount > fare["capacity"]) {
        maxCount = fare["capacity"];
      }
      final randomCount = Random().nextInt(maxCount - minCount + 1) + minCount;
      fare["count"] = randomCount.round();

      if (kDebugMode) {
        print(minCount);
        print(maxCount);
      }
    }
  }

  Future<void> _loadBids() async {
    WebComm webComm = WebComm();
    final result = await webComm.getBids(
      vaUrlController.text,
      apiKeyController.text,
      context,
    );
    try {
      if (kDebugMode) {
        print('Result: $result');
      }
      if (result == null) {
        return; // Do nothing if result is null
      } else {
        if (mounted) {
          setState(() {
            airlineIcao = result['flight']['airline']['icao'];
            airlineIata = result['flight']['airline']['iata'];
            flightNumber = result['flight']['flight_number'].toString();
            depAirport = result['flight']['dpt_airport_id'];
            arrAirport = result['flight']['arr_airport_id'];
            aircraftType = result['flight']['subfleets'][0]['type'];
            aircraftIcao =
                result['flight']['subfleets'][0]['aircraft'][0]['icao'];
            aircraftName = result['flight']['subfleets'][0]['name'];
            aircraftReg =
                result['flight']['subfleets'][0]['aircraft'][0]['registration'];
            fares = result['flight']['subfleets'][0]['fares'];
            routeController.text = result['flight']['route'];
            loadFactor = result['flight']['load_factor'].toInt();
            loadFactorVariance = result['flight']['load_factor_variance']
                .toInt();
            airlineID = result['flight']['airline']['id'];
            aircraftID = result['aircraft_id'];
            flightID = result['flight_id'];
            plannedDistance = result['flight']['distance']['nmi'];
            plannedFlightTime = result['flight']['flight_time'];
          });
          generateRandomCounts(fares, loadFactor, loadFactorVariance);
          if (flightNumber != null &&
              depAirport != null &&
              arrAirport != null) {
            bidIsLoaded = true;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing response: $e');
      }
    }
  }

  Future<void> _clearBids() async {
    setState(() {
      airlineIcao = null;
      airlineIata = null;
      flightNumber = null;
      depAirport = null;
      arrAirport = null;
      aircraftType = null;
      aircraftIcao = null;
      aircraftName = null;
      aircraftReg = null;
      fares = [];
      routeController.text = '';
      blockFuelController.text = '0';
      bidIsLoaded = false;
      loadFactor = 0;
      loadFactorVariance = 0;
      plannedDistance = 0;
      plannedFlightTime = 0;
      airlineID = 0;
      aircraftID = 0;
      flightID = null;
    });
  }

  Future<void> _loadSettings() async {
    final settings = await _storage.read(key: 'settings');
    if (settings != null) {
      final jsonSettings = jsonDecode(settings);
      vaUrlController.text = jsonSettings['vaUrl'] ?? '';
      apiKeyController.text = jsonSettings['apiKey'] ?? '';
      weightUnit = jsonSettings['weightUnit'] ?? 0;
      setState(() {});

      if (kDebugMode) {
        print(vaUrlController.text);
        print(apiKeyController.text);
      }
    }

    if (vaUrlController.text.isEmpty || apiKeyController.text.isEmpty) {
      await displayInfoBar(
        duration: Duration(seconds: 5),
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('No VA info settings found :('),
            content: const Text(
              'Please set your VA URL and API key at settings page.',
            ),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.warning,
          );
        },
      );
    }
  }

  //
  //
  //
  //
  //
  // UI
  @override
  Widget build(BuildContext context) {
    return FluentTheme(
      data: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            AppLocalizations.of(context)!.home,
            style: FluentTheme.of(context).typography.title,
          ),
        ),
        bottomBar: Container(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10.0),
          child: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: ProgressRing(
                        strokeWidth: 3,
                        backgroundColor: Colors.grey,
                      ),
                    )
                  : SizedBox(
                      width: 20,
                      height: 20,
                      child: ProgressRing(
                        strokeWidth: 3,
                        value: 0,
                        backgroundColor: Colors.grey,
                      ),
                    ),
              Button(
                onPressed: _clearBids,
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.clear),
                    SizedBox(width: 7),
                    Icon(FluentIcons.clear),
                  ],
                ),
              ),

              Button(
                onPressed:
                    vaUrlController.text.isEmpty ||
                        apiKeyController.text.isEmpty
                    ? null
                    : () async {
                        if (!_isLoading) {
                          setState(() {
                            _isLoading = true;
                          });
                        }
                        await _loadBids();
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.refresh),
                    SizedBox(width: 7),
                    Icon(FluentIcons.refresh),
                  ],
                ),
              ),

              Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                onPressed: bidIsLoaded
                    ? () {
                        Navigator.of(context, rootNavigator: true).push(
                          FluentPageRoute(
                            builder: (context) {
                              return FlightLoadingPage(
                                vaUrlController: vaUrlController,
                                apiKeyController: apiKeyController,
                                airlineID: airlineID,
                                aircraftID: aircraftID,
                                flightNumber: flightNumber ?? '',
                                airlineIcao: airlineIcao ?? '',
                                airlineIata: airlineIata ?? '',
                                blockFuel: int.parse(blockFuelController.text),
                                depAirport: depAirport ?? '',
                                arrAirport: arrAirport ?? '',
                                route: routeController.text,
                                fares: fares,
                                weightUnit: weightUnit,
                                bidID: flightID ?? '',
                                plannedDistance: plannedDistance,
                                plannedFlightTime: plannedFlightTime,
                                buildNumber: widget.buildNumber,
                              );
                            },
                          ),
                        );
                      }
                    : null,
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.startFlight),
                    SizedBox(width: 5),
                    Icon(FluentIcons.chevron_right),
                  ],
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),

        // First row, flight infos
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20.0,
            children: [
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.airline),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: airlineIcao,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.flightNumber),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: flightNumber,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.dep),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: depAirport,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 5.0,
                children: [
                  const Text(''), // empty Text widget to match height
                  const Icon(FluentIcons.airplane, size: 20.0),
                ],
              ),

              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.arr),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: arrAirport,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),

          // Second row, aircraft info
          Row(
            children: [
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.aircraftType),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: aircraftType,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aircraftIcaoCode,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: aircraftIcao,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.aircraftName),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: aircraftName,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.registration),
                    TextBox(
                      enabled: false,
                      readOnly: true,
                      style: TextStyle(fontSize: 24.0),
                      placeholder: aircraftReg,
                      placeholderStyle: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 24.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  spacing: 5.0,
                  children: [
                    Text(AppLocalizations.of(context)!.blockFuel),
                    TextBox(
                      style: TextStyle(fontSize: 24.0),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: blockFuelController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) {
                            return TextEditingValue(
                              text: '0',
                              selection: TextSelection.collapsed(offset: 1),
                            );
                          }
                          if (newValue.text.length > 7) {
                            return oldValue;
                          }
                          if (newValue.text.startsWith('0') &&
                              newValue.text.length > 1) {
                            return oldValue; // Disallow leading zeros
                          }
                          int value = int.parse(newValue.text);
                          if (value < 0 || value > 9999999) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: Row(
                  children: [
                    Column(
                      spacing: 5.0,
                      children: [
                        Text(''),
                        SizedBox(
                          width: 60,
                          child: TextBox(
                            enabled: false,
                            readOnly: true,
                            placeholder: weightUnit == 1 ? 'KG' : 'LBS',
                            placeholderStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.0),

          //fares
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: fares.isNotEmpty
                    ? fares
                          .asMap()
                          .entries
                          .map(
                            (entry) => [
                              Expanded(
                                child: Column(
                                  spacing: 5.0,
                                  children: [
                                    TextBox(
                                      enabled: false,
                                      readOnly: true,
                                      placeholder:
                                          '${entry.value['name']} (max: ${entry.value['capacity']})',
                                      placeholderStyle: TextStyle(
                                        color: Colors.grey[100],
                                        fontSize: 24.0,
                                      ),
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                              ),
                              entry.key < fares.length - 1
                                  ? SizedBox(width: 20)
                                  : Container(), // spacer
                            ],
                          )
                          .toList()
                          .expand((element) => element)
                          .toList()
                    : [
                        Expanded(
                          child: TextBox(
                            maxLines: 2,
                            readOnly: true,
                            enabled: false,
                            placeholder: AppLocalizations.of(context)!.noFares,
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Color(0xFF5178BE),
                            ),
                          ),
                        ),
                      ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: fares.isNotEmpty
                    ? fares
                          .asMap()
                          .entries
                          .map(
                            (entry) => [
                              Expanded(
                                child: NumberBox(
                                  key: ValueKey(entry.key),
                                  mode: SpinButtonPlacementMode.inline,
                                  clearButton: false,
                                  min: 0,
                                  max: entry.value['capacity'],
                                  value: (entry.value['count'] as int?) ?? 0,
                                  onChanged: (value) {
                                    setState(() {
                                      entry.value['count'] = value ?? 0;
                                    });
                                  },
                                ),
                              ),
                              entry.key < fares.length - 1
                                  ? SizedBox(width: 20)
                                  : Container(), // spacer
                            ],
                          )
                          .toList()
                          .expand((element) => element)
                          .toList()
                    : [
                        Expanded(
                          child: Container(), // spacer
                        ),
                      ],
              ),
            ],
          ),
          SizedBox(height: 20.0),

          //route
          Text(AppLocalizations.of(context)!.route),
          SizedBox(height: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 180.0,
                child: TextBox(
                  controller: routeController,
                  maxLines: null,
                  inputFormatters: [UpperCaseTextFormatter()],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[140].withAlpha(90)),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[120].withAlpha(32),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(5.0),
                child:
                    //highlight airways, assume airways are contain numbers
                    //I think this is the best way so far :(
                    //Anyone have better way?
                    Text.rich(
                      TextSpan(
                        children: routeController.text.split(' ').map((part) {
                          if (part.contains(RegExp(r'\d'))) {
                            return TextSpan(
                              text: '$part ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            );
                          } else {
                            return TextSpan(
                              text: '$part ',
                              style: TextStyle(
                                color: Colors.grey[100],
                                fontSize: 15.0,
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
