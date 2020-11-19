import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maps.dart';
import 'home_page.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

void main() async {
  /*If you're running an application and need to access the binary messenger before `runApp()` has been called (for example, during plugin initialization), then you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.*/
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await _prefs;
  String _myLocation = prefs.getString('myLocation') ?? '_';
  double _myLat = prefs.getDouble('myLat') ?? 0.0;
  double _myLng = prefs.getDouble('myLng') ?? 0.0;
  runApp(MyApp(myLocation: _myLocation, myLat: _myLat, myLng: _myLng));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final String myLocation;
  final double myLat;
  final double myLng;

  const MyApp({Key key, this.myLocation, this.myLat, this.myLng})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.00)),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.50,
            horizontal: 10.00,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            side: BorderSide(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: StadiumBorder(),
          ),
        ),
      ),
      home: (myLocation == '_' && (myLat==0.0 && myLng==0.0))
          ? MainPage(title: 'Flutter location Demo')
          : HomePage(address: myLocation, lat: myLat, lng: myLng),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Location location = Location();
  PermissionStatus _permissionGranted;
  String s;
  bool _serviceEnabled;
  String e;

  ///

  static LocationData _location;
  static double _latitude;
  static double _longitude;
  String _error;

  bool _permissionAndServiceEnabled = false;
  LatLng latLng;

  Future<void> _checkPermissions() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
    }
  }

  Future<void> _checkService() async {
    final bool serviceEnabledResult = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = serviceEnabledResult;
    });
  }

  Future<void> _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      final bool serviceRequestedResult = await location.requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
      if (!serviceRequestedResult) {
        return;
      }
    }
  }

  Future<void> _navigateToMaps() async {
    await _checkPermissions();

    if (_permissionGranted == PermissionStatus.granted) {
      await _gps();
    } else {
      await _requestPermission();

      if (_permissionGranted == PermissionStatus.granted) {
        await _gps();
      }
    }
  }

  Future _gps() async {
    await _checkService();
    if (_serviceEnabled) {
      setState(() {
        _permissionAndServiceEnabled = true;
      });

      await _getLocation();
    } else {
      await _requestService();

      if (_serviceEnabled) {
        setState(() {
          _permissionAndServiceEnabled = true;
        });

        await _getLocation();
      } else {
        setState(() {
          _permissionAndServiceEnabled = false;
        });
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
        _latitude = _location.latitude;
        _longitude = _location.longitude;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return Maps(
                        latitude: 34.73216235839068,
                        longitude: 36.713770888745785,
                      );
                    }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Set location manually',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _navigateToMaps();

                  _permissionAndServiceEnabled
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return Maps(
                              latitude: _latitude,
                              longitude: _longitude,
                            );
                          }),
                        )
                      : Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Current location',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
