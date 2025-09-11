import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'dart:convert';
import 'dart:async';
import 'package:f_acars/Flight/display_flight_data.dart';
import 'package:f_acars/web_comm.dart';
import 'dart:math';

class FlightSimComm {
  final String vaUrl;
  final String apiKey;
  final String pirepID;
  final String flightSimUrl = 'http://localhost:8000';
  final recorder = LandingDataRecorder();
  final int connectionType;
  static bool isInitFuelSaved = false;
  static bool isInitLatLonSaved = false;
  static bool isInitTimeSaved = false;
  static int initFuel = 0;
  static double initLat = 0.0;
  static double initLon = 0.0;
  static int initMonth = 0;
  static int initDay = 0;
  static int initHour = 0;
  static int initMinute = 0;

  FlightSimComm({
    required this.vaUrl,
    required this.apiKey,
    required this.pirepID,
    required this.connectionType,
  });

  double deg2rad(double deg) {
    return deg * (pi / 180.0);
  }

  double caculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var R = 3440; // Radius of the earth in nmi
    var dLat = deg2rad(lat2 - lat1);
    var dLon = deg2rad(lon2 - lon1);
    var a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = double.parse((R * c).toStringAsFixed(2)); // Distance in nmi
    return d;
  }

  Future getFlightData(
    BuildContext context, {
    VoidCallback? onError,
    VoidCallback? onRetry,
  }) async {
    try {
      Response? response;
      if (connectionType == 0) {
        response = await post(
          Uri.parse('$flightSimUrl/api/uipc'),
          body: jsonEncode({
            "requestId": "1",
            "apiVersion": "1.0",
            "dataQueries": [
              {
                "name": "AIRSPEED INDICATED (knots multed by 128)",
                "offset": "  0x02BC",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "GPS GROUND SPEED (m per s)",
                "offset": "0x6030",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "INDICATED ALTITUDE CALIBRATED SEA LEVEL(m)",
                "offset": "0x34B0",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "Radio altitude (m)",
                "offset": "0x31E4",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "GPS POSITION LAT (deg)",
                "offset": "0x6010",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "GPS POSITION LON (deg)",
                "offset": "0x6018",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "total fuel quantity weight in pounds",
                "offset": "0x126C",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "TRUE heading",
                "offset": "0x0580",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "Zulu year",
                "offset": "0x0240",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Zulu month",
                "offset": "0x0242",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu day",
                "offset": "0x023D",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu hour",
                "offset": "0x023B",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu minute",
                "offset": "0x023C",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu second",
                "offset": "0x023A",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Aircraft on ground flag",
                "offset": "0x0366",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng1 on flag",
                "offset": "0x0894",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng2 on flag",
                "offset": "0x092C",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng3 on flag",
                "offset": "0x09C4",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng4 on flag",
                "offset": "0x0A5C",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Is paused flag",
                "offset": "0x0264",
                "size": 2,
                "targetType": "int16",
              },
            ],
          }),
        );
      }
      if (connectionType == 1) {
        response = await post(
          Uri.parse('$flightSimUrl/api/uipc'),
          body: jsonEncode({
            "requestId": "1",
            "apiVersion": "1.0",
            "dataQueries": [
              {
                "name": "AIRSPEED INDICATED (knots multed by 128)",
                "offset": "  0x02BC",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "GPS GROUND SPEED (m per s)",
                "offset": "0x6030",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "INDICATED ALTITUDE CALIBRATED SEA LEVEL(m)",
                "offset": "0x34B0",
                "size": 8,
                "targetType": "float64",
              },
              {
                "name": "Radio altitude (m)",
                "offset": "0x31E4",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "GPS POSITION LAT (deg) XUIPC",
                "offset": "0x0560",
                "size": 8,
                "targetType": "xplat",
              },
              {
                "name": "GPS POSITION LON (deg) XUIPC",
                "offset": "0x0568",
                "size": 8,
                "targetType": "xplon",
              },
              {
                "name": "total fuel quantity weight in pounds",
                "offset": "0x126C",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "TRUE heading",
                "offset": "0x0580",
                "size": 4,
                "targetType": "int32",
              },
              {
                "name": "Zulu year",
                "offset": "0x0240",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Zulu month",
                "offset": "0x0242",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu day",
                "offset": "0x023D",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu hour",
                "offset": "0x023B",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu minute",
                "offset": "0x023C",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Zulu second",
                "offset": "0x023A",
                "size": 1,
                "targetType": "int8",
              },
              {
                "name": "Aircraft on ground flag",
                "offset": "0x0366",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng1 on flag",
                "offset": "0x0894",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng2 on flag",
                "offset": "0x092C",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng3 on flag",
                "offset": "0x09C4",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Eng4 on flag",
                "offset": "0x0A5C",
                "size": 2,
                "targetType": "int16",
              },
              {
                "name": "Is paused flag",
                "offset": "0x0264",
                "size": 2,
                "targetType": "int16",
              },
            ],
          }),
        );
      }
      if (response?.statusCode == 200) {
        final responseBody = jsonDecode(response!.body);
        final responseData = responseBody['dataResults'];
        final String isSucceeded = responseBody['status'] ?? 'failed';
        if (isSucceeded == 'success') {
          final airspeed = (((responseData[0]['convertedValue']) ?? 0) / 128)
              .toInt();
          final groundSpeed =
              (((responseData[1]['convertedValue']) ?? 0.0) * 1.94)
                  .toInt(); //conveted from m/s to knots
          final altCalibrated =
              (((responseData[2]['convertedValue']) ?? 0.0) * 3.28).toInt();
          final radioAltitude =
              ((((responseData[3]['convertedValue']) ?? 0) / 65536) * 3.28)
                  .toInt();
          final gpsLat = double.parse(
            (responseData[4]['convertedValue'] ?? 0.0).toStringAsFixed(4),
          );
          final gpsLon = double.parse(
            (responseData[5]['convertedValue'] ?? 0.0).toStringAsFixed(4),
          );
          final totalFuel = (responseData[6]['convertedValue']) ?? 0;
          final trueHeading =
              (((((responseData[7]['convertedValue']) ?? 0) * 360) /
                          (65536 * 65536))
                      .toInt() +
                  360) %
              360;
          final zuluYear = (responseData[8]['convertedValue']) ?? 0;
          final zuluMonth = (responseData[9]['convertedValue']) ?? 0;
          final zuluDay = (responseData[10]['convertedValue']) ?? 0;
          final zuluHour = (responseData[11]['convertedValue']) ?? 0;
          final zuluMinute = (responseData[12]['convertedValue']) ?? 0;
          final zuluSecond = (responseData[13]['convertedValue']) ?? 0;
          final isOnGround = (responseData[14]['convertedValue'] ?? 0) != 0;
          final eng1On = (responseData[15]['convertedValue']) ?? 0;
          final eng2On = (responseData[16]['convertedValue']) ?? 0;
          final eng3On = (responseData[17]['convertedValue']) ?? 0;
          final eng4On = (responseData[18]['convertedValue']) ?? 0;
          final bool isEngOn =
              eng1On == 1 || eng2On == 1 || eng3On == 1 || eng4On == 1;
          final isPaused = ((responseData[19]['convertedValue']) ?? 0) != 0;

          //calculate fuel used
          if (totalFuel != 0 && !isInitFuelSaved) {
            initFuel = totalFuel;
            isInitFuelSaved = true;
          }
          int fuelUsed = (initFuel - totalFuel).toInt();
          if (fuelUsed < 0) {
            fuelUsed = 0;
          }

          //calculate flight distance
          if ((gpsLat != 0 || gpsLon != 0.0) && !isInitLatLonSaved) {
            initLat = gpsLat;
            initLon = gpsLon;
            isInitLatLonSaved = true;
          }
          double flightDistance = caculateDistance(
            initLat,
            initLon,
            gpsLat,
            gpsLon,
          );

          //calculate flight time
          if ((zuluMonth != 0 ||
                  zuluDay != 0 ||
                  zuluHour != 0 ||
                  zuluMinute != 0) &&
              !isInitTimeSaved) {
            initMonth = zuluMonth;
            initDay = zuluDay;
            initHour = zuluHour;
            initMinute = zuluMinute;
            isInitTimeSaved = true;
          }
          Duration flightTime = Duration(
            days: zuluDay - initDay,
            hours: zuluHour - initHour,
            minutes: zuluMinute - initMinute,
          );

          //calculate off/on block time
          String offBlockTime = "N/A";
          String onBlockTime = "N/A";
          if (FlightStatusUpdate.offBlockTimeValid) {
            offBlockTime = FlightStatusUpdate.offBlockTime;
          }

          if (FlightStatusUpdate.onBlockTimeValid) {
            onBlockTime = FlightStatusUpdate.onBlockTime;
          }

          if (radioAltitude < 200 &&
              !LandingDataRecorder.isStarted &&
              FlightStatusUpdate.currentStatus == FlightStatus.LDG &&
              context.mounted) {
            if (kDebugMode) {
              print('Try to start');
            }
            LandingDataRecorder.startTimer(context);
            if (kDebugMode) {
              print(
                'maxLandingVS: ${LandingDataRecorder.landingVS}, maxLandingG: ${LandingDataRecorder.landingG}',
              );
            }
          }
          if ((radioAltitude > 200 ||
                  FlightStatusUpdate.currentStatus != FlightStatus.LDG) &&
              LandingDataRecorder.isStarted) {
            LandingDataRecorder.stopTimer();
          }

          if (FlightDataDisplayState.statusAutoUpdate) {
            FlightStatusUpdate.updateStatus(
              groundSpeed,
              radioAltitude,
              isEngOn,
              isOnGround,
              vaUrl,
              apiKey,
              pirepID,
              isPaused,
              zuluYear,
              zuluMonth,
              zuluDay,
              zuluHour,
              zuluMinute,
              zuluSecond,
            );
          }

          return {
            'airspeed': airspeed,
            'groundSpeed': groundSpeed,
            'altCalibrated': altCalibrated,
            'radioAltitude': radioAltitude,
            'gpsLat': gpsLat,
            'gpsLon': gpsLon,
            'flightDistance': flightDistance,
            'totalFuel': totalFuel,
            'fuelUsed': fuelUsed,
            'trueHeading': trueHeading,
            'zuluYear': zuluYear,
            'zuluMonth': zuluMonth,
            'zuluDay': zuluDay,
            'zuluHour': zuluHour,
            'zuluMinute': zuluMinute,
            'zuluSecond': zuluSecond,
            'flightTime': flightTime.inMinutes,
            'offBlockTime': offBlockTime,
            'onBlockTime': onBlockTime,
            'isOnGround': isOnGround,
            'isEngOn': isEngOn,
            'landingVS': LandingDataRecorder.landingVS,
            'landingG': LandingDataRecorder.landingG,
            'flightStatus':
                {
                  FlightStatus.INI: 'Initiated',
                  FlightStatus.BST: 'Boarding',
                  FlightStatus.TXI: 'Taxi',
                  FlightStatus.TOF: 'Takeoff',
                  FlightStatus.ICL: 'Initial Climb',
                  FlightStatus.ENR: 'Enroute',
                  FlightStatus.TEN: 'Approach',
                  FlightStatus.LDG: 'Landing',
                  FlightStatus.LAN: 'Landed',
                  FlightStatus.ARR: 'Arrived',
                  FlightStatus.PSD: 'Paused',
                }[FlightStatusUpdate.currentStatus] ??
                'Unknown Status',
          };
        } else {
          throw Exception(
            'Failed to get flight data. Disconnect from the game.',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (context.mounted) {
        onError?.call();
        showConnectionError(context, e, onRetry);
      }
    }
  }
}

//
//
//
//
//
class LandingDataRecorder {
  static final String flightSimUrl = 'http://localhost:8000';
  static Timer? _timer;
  BuildContext? context;
  static bool isGettingData = false;
  static bool isTryToStop = false;
  static bool isStarted = false;

  static int landingVS = 0;
  static double landingG = 0.0;

  static void startTimer(BuildContext context) {
    isStarted = true;
    isTryToStop = false;
    if (isGettingData) {
      return;
    } else {
      isGettingData = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (kDebugMode) {
          print('timer running!');
        }
        if (!isTryToStop) {
          if (kDebugMode) {
            print('fetching landing data...');
          }
          try {
            post(
              Uri.parse('$flightSimUrl/api/uipc'),
              body: jsonEncode({
                "requestId": "1",
                "apiVersion": "1.0",
                "dataQueries": [
                  {
                    "name": "Landing V/S (mps)",
                    "offset": "0x030C",
                    "size": 4,
                    "targetType": "int32",
                  },
                  {
                    "name": "Landing G (*624)",
                    "offset": "0x11B8",
                    "size": 2,
                    "targetType": "int16",
                  },
                  {
                    "name": "Aircraft on ground flag",
                    "offset": "0x0366",
                    "size": 2,
                    "targetType": "int16",
                  },
                ],
              }),
            ).then((response) {
              isGettingData = false;
              if (response.statusCode == 200) {
                final responseBody = jsonDecode(response.body);
                final responseData = responseBody['dataResults'];
                final String isSucceeded = responseBody['status'] ?? 'failed';
                if (isSucceeded == 'success') {
                  final isOnGround =
                      (responseData[2]['convertedValue'] ?? 0) != 0;
                  if (isOnGround) {
                    final landingVSNew =
                        (((responseData[0]['convertedValue']) ?? 0) *
                                (60 * 3.28084 / 256))
                            .toInt();
                    final landingGNew = double.parse(
                      ((responseData[1]['convertedValue'] ?? 0.0) / 624)
                          .toStringAsFixed(2),
                    );
                    if (landingVSNew < landingVS) {
                      landingVS = landingVSNew;
                      if (kDebugMode) {
                        print('landingVS: $landingVS');
                      }
                    }
                    if (landingGNew > landingG) {
                      landingG = landingGNew;
                      if (kDebugMode) {
                        print('landingG: $landingG');
                      }
                    }
                  }
                }
              }
            });
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
            stopTimer();
            if (context.mounted) {
              showConnectionError(context, e, () => startTimer(context));
            }
          }
        }
      });
    }
  }

  static void stopTimer() {
    if (kDebugMode) {
      print('Try to stop');
    }
    isTryToStop = true;
    isStarted = false;
    isGettingData = false;
    _timer?.cancel();
    _timer = null;
  }
}

//
//
//
//
//
//Flight Status update
enum FlightStatus {
  INI, // initiated
  BST, // boarding
  TXI, // taxi
  TOF, // takeoff
  ICL, // initial climb
  ENR, // enroute
  TEN, // approach
  LDG, // landing
  LAN, // landed
  ARR, // arrived
  PSD, // paused
}

class FlightStatusUpdate {
  static FlightStatus currentStatus = FlightStatus.INI;
  static FlightStatus statusBeforePause = FlightStatus.INI;
  static String offBlockTime = 'N/A';
  static bool offBlockTimeValid = false;
  static String onBlockTime = 'N/A';
  static bool onBlockTimeValid = false;

  static void updateStatus(
    int gs,
    int ra,
    bool isEngOn,
    bool onGround,
    String vaUrl,
    String apiKey,
    String pirepID,
    bool isPaused,
    int zuluYear,
    int zuluMonth,
    int zuluDay,
    int zuluHour,
    int zuluMinute,
    int zuluSecond,
  ) {
    switch (currentStatus) {
      case FlightStatus.INI:
        currentStatus = FlightStatus.BST;
        WebComm().updateStatus(vaUrl, apiKey, pirepID, 'BST');
        FlightDataDisplayState.resetWebUploadDelay();
        break;
      case FlightStatus.BST:
        if (isEngOn && gs > 5) {
          currentStatus = FlightStatus.TXI;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'TXI');
          if (!offBlockTimeValid) {
            offBlockTime =
                "$zuluYear-$zuluMonth-${zuluDay}T$zuluHour:$zuluMinute:${zuluSecond}Z";
            offBlockTimeValid = true;
          }
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.TXI:
        if (gs > 45 && onGround) {
          currentStatus = FlightStatus.TOF;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'TOF');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.TOF:
        if (!onGround && gs > 60) {
          currentStatus = FlightStatus.ICL;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'ICL');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.ICL:
        if (ra > 5000) {
          currentStatus = FlightStatus.ENR;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'ENR');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.ENR:
        if (ra < 4000) {
          currentStatus = FlightStatus.TEN;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'TEN');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.TEN:
        if (ra < 2500) {
          currentStatus = FlightStatus.LDG;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'LDG');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.LDG:
        if (onGround && gs < 60) {
          currentStatus = FlightStatus.LAN;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'LAN');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      case FlightStatus.LAN:
        if (!isEngOn && gs == 0) {
          currentStatus = FlightStatus.ARR;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'ARR');
          if (!onBlockTimeValid) {
            onBlockTime =
                "$zuluYear-$zuluMonth-${zuluDay}T$zuluHour:$zuluMinute:${zuluSecond}Z";
            onBlockTimeValid = true;
          }
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if (isPaused) {
          statusBeforePause = currentStatus;
          currentStatus = FlightStatus.PSD;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'PSD');
          FlightDataDisplayState.resetWebUploadDelay();
        }
        if ((!onGround && gs > 60) || ra > 200) {
          currentStatus = FlightStatus.LDG;
          WebComm().updateStatus(vaUrl, apiKey, pirepID, 'LDG');
          FlightDataDisplayState.resetWebUploadDelay();
          LandingDataRecorder.landingVS = 0;
          LandingDataRecorder.landingG = 0.0;
        }
        break;
      case FlightStatus.PSD:
        if (!isPaused) {
          currentStatus = statusBeforePause;
          WebComm().updateStatus(
            vaUrl,
            apiKey,
            pirepID,
            currentStatus.toString().substring(
              currentStatus.toString().length - 3,
            ),
          );
          FlightDataDisplayState.resetWebUploadDelay();
        }
        break;
      default:
        break;
    }
  }
}

//
//
//
//
//
//
void showConnectionError(BuildContext context, e, VoidCallback? onRetry) async {
  await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('Connection error!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Text(
            'There is an error occurred while get data and send to the server.',
          ),
          Container(
            decoration: BoxDecoration(
              color: FluentTheme.of(
                context,
              ).resources.controlStrokeColorSecondary,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: FluentTheme.of(
                  context,
                ).resources.controlStrokeColorSecondary,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text(e.toString()),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Retry'),
          onPressed: () {
            Navigator.pop(context);
            onRetry?.call();
          },
        ),
      ],
    ),
  );
}
