import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:f_acars/flight_sim_comm.dart';
import 'package:f_acars/web_comm.dart';
import 'package:f_acars/main.dart';
import 'dart:async';
import 'dart:io';

class FlightData {
  int airspeed;
  int groundSpeed;
  int altCalibrated;
  int radioAltitude;
  double gpsLat;
  double gpsLon;
  double flightDistance;
  int totalFuel;
  int fuelUsed;
  int trueHeading;
  int zuluYear;
  int zuluMonth;
  int zuluDay;
  int zuluHour;
  int zuluMinute;
  int zuluSecond;
  int flightTime;
  String offBlockTime;
  String onBlockTime;
  bool isOnGround;
  bool isEngOn;
  int landingVS;
  double landingG;
  String flightStatus;

  FlightData({
    required this.airspeed,
    required this.groundSpeed,
    required this.altCalibrated,
    required this.radioAltitude,
    required this.gpsLat,
    required this.gpsLon,
    required this.flightDistance,
    required this.totalFuel,
    required this.fuelUsed,
    required this.trueHeading,
    required this.zuluYear,
    required this.zuluMonth,
    required this.zuluDay,
    required this.zuluHour,
    required this.zuluMinute,
    required this.zuluSecond,
    required this.flightTime,
    required this.offBlockTime,
    required this.onBlockTime,
    required this.isOnGround,
    required this.isEngOn,
    required this.landingVS,
    required this.landingG,
    required this.flightStatus,
  });
}

class FlightDataDisplay extends StatefulWidget {
  final String vaUrl;
  final String apiKey;
  final String pirepID;
  static int webUploadDelay = 1;

  const FlightDataDisplay({
    super.key,
    required this.vaUrl,
    required this.apiKey,
    required this.pirepID,
  });

  @override
  FlightDataDisplayState createState() => FlightDataDisplayState();
}

class FlightDataDisplayState extends State<FlightDataDisplay> {
  static bool statusAutoUpdate = true;
  bool _isFetchingData = false;
  Timer? _timer;
  final ValueNotifier<FlightData> _flightDataNotifier = ValueNotifier(
    FlightData(
      airspeed: 0,
      groundSpeed: 0,
      altCalibrated: 0,
      radioAltitude: 0,
      gpsLat: 0.0,
      gpsLon: 0.0,
      flightDistance: 0.0,
      totalFuel: 0,
      fuelUsed: 0,
      trueHeading: 0,
      zuluYear: 0,
      zuluMonth: 0,
      zuluDay: 0,
      zuluHour: 0,
      zuluMinute: 0,
      zuluSecond: 0,
      flightTime: 0,
      offBlockTime: 'N/A',
      onBlockTime: 'N/A',
      isOnGround: false,
      isEngOn: false,
      landingVS: 0,
      landingG: 0.0,
      flightStatus: 'N/A',
    ),
  );
  FlightStatus selectedValue = FlightStatus.INI;

  @override
  void initState() {
    super.initState();
    statusAutoUpdate = true;
    startTimer();
  }

  @override
  void dispose() {
    stopConnector();
    _timer?.cancel();
    super.dispose();
  }

  bool startConnector() {
    try {
      Process.run('UIPCDemo32.exe', [])
          .then((process) {
            if (kDebugMode) {
              print('Command executed successfully');
            }
          })
          .catchError((error) {
            if (kDebugMode) {
              print('Error executing command: $error');
            }
          });
      return true;
    } catch (_) {
      return false;
    }
  }

  bool stopConnector() {
    try {
      Process.run('cmd', ['/c', 'taskkill /F /IM UIPCDemo32.exe'])
          .then((process) {
            if (kDebugMode) {
              print('Command executed successfully');
              print(process.stdout);
              print(process.stderr);
            }
          })
          .catchError((error) {
            if (kDebugMode) {
              print('Error executing command: $error');
            }
          });
      return true;
    } catch (_) {
      return false;
    }
  }

  static void resetWebUploadDelay() {
    /*Read data from game every 3 sec, so if you want to upload data to web, for example,every 5 min = 5*60/3 = 100 */
    if (FlightStatusUpdate.currentStatus == FlightStatus.INI) {
      FlightDataDisplay.webUploadDelay = 200;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.BST) {
      FlightDataDisplay.webUploadDelay = 100;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.TXI) {
      FlightDataDisplay.webUploadDelay = 4;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.TOF) {
      FlightDataDisplay.webUploadDelay = 4;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.ICL) {
      FlightDataDisplay.webUploadDelay = 5;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.ENR) {
      FlightDataDisplay.webUploadDelay = 100;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.TEN) {
      FlightDataDisplay.webUploadDelay = 10;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.LDG) {
      FlightDataDisplay.webUploadDelay = 5;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.LAN) {
      FlightDataDisplay.webUploadDelay = 4;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.ARR) {
      FlightDataDisplay.webUploadDelay = 100;
    }
    if (FlightStatusUpdate.currentStatus == FlightStatus.PSD) {
      FlightDataDisplay.webUploadDelay = 300;
    }
  }

  void startTimer() {
    WebComm webComm = WebComm();
    startConnector();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_isFetchingData) {
        _isFetchingData = true;
        FlightSimComm(
          vaUrl: widget.vaUrl,
          apiKey: widget.apiKey,
          pirepID: widget.pirepID,
        ).getFlightData(context, onError: stopTimer, onRetry: startTimer).then((
          data,
        ) {
          if (data != null) {
            _flightDataNotifier.value = FlightData(
              airspeed: data['airspeed'] ?? 0,
              groundSpeed: data['groundSpeed'] ?? 0,
              altCalibrated: data['altCalibrated'] ?? 0,
              radioAltitude: data['radioAltitude'] ?? 0,
              gpsLat: data['gpsLat'] ?? 0.0,
              gpsLon: data['gpsLon'] ?? 0.0,
              flightDistance: data['flightDistance'] ?? 0.0,
              totalFuel: data['totalFuel'] ?? 0,
              fuelUsed: data['fuelUsed'] ?? 0,
              trueHeading: data['trueHeading'] ?? 0,
              zuluYear: data['zuluYear'] ?? 0,
              zuluMonth: data['zuluMonth'] ?? 0,
              zuluDay: data['zuluDay'] ?? 0,
              zuluHour: data['zuluHour'] ?? 0,
              zuluMinute: data['zuluMinute'] ?? 0,
              zuluSecond: data['zuluSecond'] ?? 0,
              flightTime: data['flightTime'] ?? 0,
              offBlockTime: data['offBlockTime'] ?? 'N/A',
              onBlockTime: data['onBlockTime'] ?? 'N/A',
              isOnGround: data['isOnGround'] ?? false,
              isEngOn: data['isEngOn'] ?? false,
              landingVS: data['landingVS'] ?? 0,
              landingG: data['landingG'] ?? 0.0,
              flightStatus: data['flightStatus'] ?? 'N/A',
            );
          }
          _isFetchingData = false;
        });
        if (FlightDataDisplay.webUploadDelay > 1) {
          FlightDataDisplay.webUploadDelay =
              FlightDataDisplay.webUploadDelay - 1;
        } else {
          resetWebUploadDelay();
          webComm
              .updatePosition(
                widget.vaUrl,
                widget.apiKey,
                widget.pirepID,
                _flightDataNotifier.value.gpsLat,
                _flightDataNotifier.value.gpsLon,
                _flightDataNotifier.value.altCalibrated,
                _flightDataNotifier.value.groundSpeed,
                _flightDataNotifier.value.trueHeading,
                _flightDataNotifier.value.totalFuel,
                _flightDataNotifier.value.zuluYear,
                _flightDataNotifier.value.zuluMonth,
                _flightDataNotifier.value.zuluDay,
                _flightDataNotifier.value.zuluHour,
                _flightDataNotifier.value.zuluMinute,
                _flightDataNotifier.value.zuluSecond,
                context,
              )
              .then((result) {
                if (result is Exception) {
                  if (kDebugMode) {
                    print('Error updating position: $result');
                  }
                  stopTimer();
                  showConnectionError(context, result, startTimer);
                }
              });
          webComm
              .updatePirep(
                widget.vaUrl,
                widget.apiKey,
                widget.pirepID,
                _flightDataNotifier.value.flightDistance,
                _flightDataNotifier.value.fuelUsed,
                _flightDataNotifier.value.flightTime,
                context,
              )
              .then((result) {
                if (result is Exception) {
                  if (kDebugMode) {
                    print('Error updating pireps: $result');
                  }
                  stopTimer();
                  showConnectionError(context, result, startTimer);
                }
              });
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    stopConnector();
  }

  Future fileCompletePirep() async {
    if (FlightStatusUpdate.offBlockTimeValid &&
        FlightStatusUpdate.onBlockTimeValid) {
      await WebComm().fileCompletePirepWithBlockTime(
        widget.vaUrl,
        widget.apiKey,
        widget.pirepID,
        _flightDataNotifier.value.flightTime,
        _flightDataNotifier.value.fuelUsed,
        _flightDataNotifier.value.flightDistance,
        _flightDataNotifier.value.offBlockTime,
        _flightDataNotifier.value.onBlockTime,
        _flightDataNotifier.value.landingVS,
      );
    } else {
      await WebComm().fileCompletePirep(
        widget.vaUrl,
        widget.apiKey,
        widget.pirepID,
        _flightDataNotifier.value.flightTime,
        _flightDataNotifier.value.fuelUsed,
        _flightDataNotifier.value.flightDistance,
        _flightDataNotifier.value.landingVS,
      );
    }
  }

  void showQuitFlightDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Are you sure to quit?'),
        content: const Text(
          'Choose "Quit only" to quit without filing a completed pirep. Choose "Quit & file" to quit and file the completed pirep.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Button(
            child: const Text('Quit only'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                FluentPageRoute(builder: (context) => MyApp()),
                (route) => false,
              );
            },
          ),
          FilledButton(
            child: const Text('Quit & file'),
            onPressed: () {
              fileCompletePirep();
              Navigator.pushAndRemoveUntil(
                context,
                FluentPageRoute(builder: (context) => MyApp()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  //
  //
  //
  //
  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      children: [
        FlightDataText(flightDataNotifier: _flightDataNotifier),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Text('Status auto update'),
            ToggleSwitch(
              checked: statusAutoUpdate,
              onChanged: (v) => setState(() => statusAutoUpdate = v),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            ComboBox(
              value: selectedValue,
              onChanged: statusAutoUpdate
                  ? null
                  : (value) {
                      setState(() {
                        selectedValue =
                            value as FlightStatus? ?? FlightStatus.BST;
                      });
                    },
              items: [
                ComboBoxItem(value: FlightStatus.BST, child: Text('Boarding')),
                ComboBoxItem(value: FlightStatus.TXI, child: Text('Taxi')),
                ComboBoxItem(value: FlightStatus.TOF, child: Text('Takeoff')),
                ComboBoxItem(
                  value: FlightStatus.ICL,
                  child: Text('Initial climb'),
                ),
                ComboBoxItem(value: FlightStatus.ENR, child: Text('Enroute')),
                ComboBoxItem(value: FlightStatus.TEN, child: Text('Approach')),
                ComboBoxItem(value: FlightStatus.LDG, child: Text('Landing')),
                ComboBoxItem(value: FlightStatus.LAN, child: Text('Landed')),
                ComboBoxItem(value: FlightStatus.ARR, child: Text('Arrived')),
                ComboBoxItem(value: FlightStatus.PSD, child: Text('Paused')),
              ],
            ),
            Button(
              onPressed: statusAutoUpdate
                  ? null
                  : () {
                      setState(() {
                        FlightStatusUpdate.currentStatus = selectedValue;
                        WebComm().updateStatus(
                          widget.vaUrl,
                          widget.apiKey,
                          widget.pirepID,
                          selectedValue.toString().substring(
                            selectedValue.toString().length - 3,
                          ),
                        );
                        resetWebUploadDelay();
                      });
                    },
              child: Text('Update'),
            ),
          ],
        ),
        Button(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 7,
            children: [Text('quit'), Icon(FluentIcons.clear)],
          ),
          onPressed: () {
            showQuitFlightDialog(context);
          },
        ),
      ],
    );
  }
}

class FlightDataText extends StatelessWidget {
  final ValueNotifier<FlightData> flightDataNotifier;
  const FlightDataText({super.key, required this.flightDataNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: flightDataNotifier,
      builder: (context, flightData, child) {
        return Column(
          children: [
            Text(
              'Airspeed: ${flightData.airspeed} kts \nGround speed: ${flightData.groundSpeed} kts \nCalibrated altitude: ${flightData.altCalibrated} ft \nRadio altitude: ${flightData.radioAltitude} ft \nLat: ${flightData.gpsLat}° \nLon: ${flightData.gpsLon}° \nFlight distance: ${flightData.flightDistance} nm\nTotal fuel: ${flightData.totalFuel} lbs \nFuel used: ${flightData.fuelUsed} lbs\nTrue heading: ${flightData.trueHeading}° \nSim zulu time: ${flightData.zuluYear}-${flightData.zuluMonth}-${flightData.zuluDay}   ${flightData.zuluHour}:${flightData.zuluMinute}:${flightData.zuluSecond} \nFlight time: ${flightData.flightTime} mins \nOff block time: ${flightData.offBlockTime} \nOn block time: ${flightData.onBlockTime} \nOn ground: ${flightData.isOnGround == true ? 'True' : 'False'} \nEngine running: ${flightData.isEngOn == true ? 'True' : 'False'}\nLandingVS: ${flightData.landingVS} fpm\nLandingG: ${flightData.landingG} g\n\nflight status: ${flightData.flightStatus}\nWeb upload delay: ${FlightDataDisplay.webUploadDelay}',
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ],
        );
      },
    );
  }
}
