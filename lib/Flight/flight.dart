import 'package:fluent_ui/fluent_ui.dart';
import 'package:f_acars/l10n/app_localizations.dart';
import 'package:f_acars/Flight/display_flight_data.dart';

class FlightPage extends StatelessWidget {
  final String flightID;
  final String airlineIcao;
  final String airlineIata;
  final String flightNumber;
  final String depAirport;
  final String arrAirport;
  final int blockFuel;
  final int weightUnit;
  final String route;
  final List<dynamic> fares;
  final String apiKey;
  final String vaUrl;

  final int buildNumber;

  const FlightPage({
    super.key,
    required this.flightID,
    required this.airlineIcao,
    required this.airlineIata,
    required this.flightNumber,
    required this.depAirport,
    required this.arrAirport,
    required this.blockFuel,
    required this.weightUnit,
    required this.route,
    required this.fares,
    required this.apiKey,
    required this.vaUrl,

    required this.buildNumber,
  });

  @override
  Widget build(BuildContext context) {
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
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            '$airlineIcao / $airlineIata $flightNumber',
            style: FluentTheme.of(context).typography.titleLarge,
          ),
        ),
        children: [
          SizedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 20,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Column(
                          spacing: 20,
                          children: [
                            Row(
                              spacing: 30,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  depAirport,
                                  style: FluentTheme.of(
                                    context,
                                  ).typography.title,
                                ),
                                Icon(FluentIcons.airplane, size: 20.0),
                                Text(
                                  arrAirport,
                                  style: FluentTheme.of(
                                    context,
                                  ).typography.title,
                                ),
                              ],
                            ),

                            //show block fuel
                            Text(
                              '${AppLocalizations.of(context)!.blockFuel}  $blockFuel  ${weightUnit == 1 ? 'kg' : 'lbs'}',
                              style: FluentTheme.of(
                                context,
                              ).typography.subtitle,
                            ),

                            Text(
                              AppLocalizations.of(context)!.fares,
                              style: FluentTheme.of(
                                context,
                              ).typography.subtitle,
                            ),
                            //show fares in a table
                            Table(
                              border: TableBorder(
                                top: BorderSide(
                                  color: FluentTheme.of(
                                    context,
                                  ).resources.controlStrokeColorSecondary,
                                  width: 2,
                                ),
                                horizontalInside: BorderSide(
                                  color: FluentTheme.of(
                                    context,
                                  ).resources.controlStrokeColorSecondary,
                                ),
                                bottom: BorderSide(
                                  color: FluentTheme.of(
                                    context,
                                  ).resources.controlStrokeColorSecondary,
                                  width: 2,
                                ),
                              ),

                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.aircraftName, //just use name, same
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text(
                                        AppLocalizations.of(context)!.code,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text(
                                        AppLocalizations.of(context)!.count,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ...fares.map((fare) {
                                  return TableRow(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(fare['name'].toString()),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(fare['code'].toString()),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(fare['count'].toString()),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),

                            Text(
                              AppLocalizations.of(context)!.route,
                              style: FluentTheme.of(
                                context,
                              ).typography.subtitle,
                            ),
                            //show high lighted routes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[140].withAlpha(90),
                                      ),
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
                                        Center(
                                          child: Text.rich(
                                            TextSpan(
                                              children: route.split(' ').map((
                                                part,
                                              ) {
                                                if (part.contains(
                                                  RegExp(r'\d'),
                                                )) {
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //
                //
                //display flight data
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 30),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: FluentTheme.of(
                            context,
                          ).resources.controlStrokeColorSecondary,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        FlightDataDisplay(
                          vaUrl: vaUrl,
                          apiKey: apiKey,
                          pirepID: flightID,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
