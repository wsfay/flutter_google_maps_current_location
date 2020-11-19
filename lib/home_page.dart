import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'maps.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class HomePage extends StatefulWidget {
  final String address;
  final double lat;
  final double lng;

  const HomePage({Key key, this.address, this.lat, this.lng})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _myLocation;
  double _myLat;
  double _myLng;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Text('Your location=>  ${widget.address}'),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Text('${widget.lat} , ${widget.lng}'),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return Maps(
                        latitude: widget.lat,
                        longitude: widget.lng,
                      );
                    }),
                  ),
                  child: Text(
                    'Change location',
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
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await _prefs;
                    setState(() {
                      _clearSavedLocationData(prefs);
                      prefs.reload();
                      _readSavedLocationData(prefs);
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return MyApp(myLocation: _myLocation, myLat: _myLat, myLng: _myLng);
                      }),
                    );
                  },
                  child: Text(
                    'CLEAR SAVED LOCATION',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  void _clearSavedLocationData(SharedPreferences prefs) {
    prefs.remove('myLocation');
    prefs.remove('myLat');
    prefs.remove('myLng');
  }

  void _readSavedLocationData(SharedPreferences prefs) {
    _myLocation = prefs.getString('myLocation') ?? '_';
    _myLat = prefs.getDouble('myLat') ?? 0.0;
    _myLng = prefs.getDouble('myLng') ?? 0.0;
  }
}
