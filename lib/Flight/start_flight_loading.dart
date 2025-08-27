import 'package:fluent_ui/fluent_ui.dart';
import 'flight.dart';
import 'package:f_acars/web_comm.dart';
import 'package:f_acars/l10n/app_localizations.dart';
import 'package:f_acars/flight_sim_comm.dart';

class FlightLoadingPage extends StatelessWidget {
  final TextEditingController vaUrlController;
  final TextEditingController apiKeyController;
  final int airlineID;
  final int aircraftID;
  final String airlineIcao;
  final String airlineIata;
  final String flightNumber;
  final int blockFuel;
  final String depAirport;
  final String arrAirport;
  final String route;
  final List<dynamic> fares;
  final String bidID;
  final num plannedDistance;
  final int plannedFlightTime;

  final int weightUnit;
  final int buildNumber;

  const FlightLoadingPage({
    super.key,
    required this.vaUrlController,
    required this.apiKeyController,
    required this.airlineID,
    required this.aircraftID,
    required this.airlineIcao,
    required this.airlineIata,
    required this.flightNumber,
    required this.blockFuel,
    required this.depAirport,
    required this.arrAirport,
    required this.route,
    required this.fares,
    required this.bidID,
    required this.plannedDistance,
    required this.plannedFlightTime,

    required this.weightUnit,
    required this.buildNumber,
  });

  @override
  Widget build(BuildContext context) {
    int blockFuelConverted = blockFuel;
    if (weightUnit == 1) {
      //if is kg, to lbs
      blockFuelConverted = (blockFuel * 2.2046226218).toInt();
    }
    WebComm()
        .prefilePireps(
          vaUrlController.text,
          apiKeyController.text,
          context,
          airlineID,
          aircraftID,
          bidID,
          depAirport,
          arrAirport,
          flightNumber,
          route,
          plannedDistance,
          plannedFlightTime,
          blockFuelConverted,
          fares,
        )
        .then((result) {
          FlightSimComm.isInitFuelSaved = false;
          FlightSimComm.initFuel = 0;
          FlightSimComm.isInitLatLonSaved = false;
          FlightSimComm.initLat = 0;
          FlightSimComm.initLon = 0;
          FlightSimComm.isInitTimeSaved = false;
          FlightSimComm.initDay = 0;
          FlightSimComm.initHour = 0;
          FlightSimComm.initMinute = 0;
          FlightStatusUpdate.currentStatus = FlightStatus.INI;
          LandingDataRecorder.landingVS = 0;
          LandingDataRecorder.landingG = 0;
          FlightStatusUpdate.offBlockTimeValid = false;
          FlightStatusUpdate.onBlockTimeValid = false;
          FlightStatusUpdate.offBlockTime = 'N/A';
          FlightStatusUpdate.onBlockTime = 'N/A';
          String flightID = result?['id'] ?? 'null';
          if (flightID != 'null' && context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              FluentPageRoute(
                builder: (context) => FlightPage(
                  flightID: flightID,
                  airlineIcao: airlineIcao,
                  airlineIata: airlineIata,
                  flightNumber: flightNumber,
                  depAirport: depAirport,
                  arrAirport: arrAirport,
                  blockFuel: blockFuel,
                  weightUnit: weightUnit,
                  route: route,
                  fares: fares,
                  vaUrl: vaUrlController.text,
                  apiKey: apiKeyController.text,
                  buildNumber: buildNumber,
                ),
              ),
              (route) => false,
            );
          }
        });
    return FluentTheme(
      data: buildNumber >= 22000
          ? FluentThemeData(
              micaBackgroundColor: Colors.transparent,
              brightness: Brightness.dark,
              accentColor: Colors.blue,
              scaffoldBackgroundColor: Colors.transparent,
            )
          : FluentThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.blue,
            ),
      child: ScaffoldPage(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                SizedBox(height: 50, width: 50, child: ProgressRing()),
                Text(AppLocalizations.of(context)!.prefiling),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
