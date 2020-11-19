import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

const String API_KEY = 'YOUR_API_KEY';

class Maps extends StatefulWidget {
  final double latitude;
  final double longitude;

  const Maps({Key key, this.latitude, this.longitude}) : super(key: key);
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  LatLng _tapped;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;

  CameraPosition _position;
  double _zoom;

  bool isMarkerAdded;
  int countOfMarkers = 0;
  Address _address;
  Address _myCurrentAddress;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  double _screenHeight;
  void _getLatLng(Prediction prediction) async {
    GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: API_KEY);
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(prediction.placeId);
    double latitude = detail.result.geometry.location.lat;
    double longitude = detail.result.geometry.location.lng;
    _newPositionSearch(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    //print('height: $screenHeight');
    return Scaffold(
      appBar: AppBar(
        title: Text('Select location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search location',
            onPressed: () async {
              print('object');
              Prediction prediction = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: API_KEY,
                  mode: Mode.fullscreen, // Mode.overlay
                  language: "en",
                  components: [Component(Component.country, "pk")]);
              _getLatLng(prediction);
            },
          ),
        ],
      ),
      body: _buildBodyWidgets(),
    );
  }

  Widget _buildBodyWidgets(){
    Widget _widget;
    (_screenHeight >= 400)? _widget = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              flex: 5,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _currentLocation(),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: Set<Marker>.of(markers.values),
                onTap: (LatLng pos) async {
                  setState(() {
                    _tapped = pos;
//_myCurrentAddress = null;
                  });
                  await _findAddressesFromCoordinates(_tapped);
                  if (markers.length >= 1) {
                    markers.clear();
                  }
                  if (markers.length == 0) {
                    final GoogleMapController controller =
                        await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(_newPosition(pos)));

                    _add(pos);
                  }
                },
                onCameraMove: _onCameraMove,
              )),
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: (_address != null)
                        ? ((_address.adminArea != null)
                            ? Text(
                                '${_address.adminArea} ${_address.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                '${_address.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                        : (_myCurrentAddress != null)
                            ? Text(
                                '${_myCurrentAddress.adminArea} ${_myCurrentAddress.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(''),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: ElevatedButton(
                       style: ElevatedButton.styleFrom(primary: Colors.blue[900], elevation: 8.0,),
                      onPressed: () async {
                        await _saveLocationInSharedPrefs(
                            _address,
                            _myCurrentAddress,
                            _position,
                            widget.latitude,
                            widget.longitude);

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return (_address != null)
                              ? HomePage(
                                  address:
                                      '${_address.adminArea} ${_address.addressLine}',
                                  lat: _position.target.latitude,
                                  lng: _position.target.longitude,
                                )
                              : HomePage(
                                  address:
                                      '${_myCurrentAddress.adminArea} ${_myCurrentAddress.addressLine}',
                                  lat: widget.latitude,
                                  lng: widget.longitude,
                                );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: Text(
                          'SAVE LOCATION',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ): _widget = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              flex: 4,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _currentLocation(),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: Set<Marker>.of(markers.values),
                onTap: (LatLng pos) async {
                  setState(() {
                    _tapped = pos;
//_myCurrentAddress = null;
                  });
                  await _findAddressesFromCoordinates(_tapped);
                  if (markers.length >= 1) {
                    markers.clear();
                  }
                  if (markers.length == 0) {
                    final GoogleMapController controller =
                        await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(_newPosition(pos)));

                    _add(pos);
                  }
                },
                onCameraMove: _onCameraMove,
              )),
          Expanded(
            flex: 3,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: (_address != null)
                        ? ((_address.adminArea != null)
                            ? Text(
                                '${_address.adminArea} ${_address.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                '${_address.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                        : (_myCurrentAddress != null)
                            ? Text(
                                '${_myCurrentAddress.adminArea} ${_myCurrentAddress.addressLine}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(''),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: ElevatedButton(
                       style: ElevatedButton.styleFrom(primary: Colors.blue[900], elevation: 8.0,),
                      onPressed: () async {
                        await _saveLocationInSharedPrefs(
                            _address,
                            _myCurrentAddress,
                            _position,
                            widget.latitude,
                            widget.longitude);

                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return (_address != null)
                              ? HomePage(
                                  address:
                                      '${_address.adminArea} ${_address.addressLine}',
                                  lat: _position.target.latitude,
                                  lng: _position.target.longitude,
                                )
                              : HomePage(
                                  address:
                                      '${_myCurrentAddress.adminArea} ${_myCurrentAddress.addressLine}',
                                  lat: widget.latitude,
                                  lng: widget.longitude,
                                );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: Text(
                          'SAVE LOCATION',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );

      return _widget;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    setState(() {
      _position = cameraPosition;
      _zoom = cameraPosition.zoom;
    });
    _findNameFromLatLng(_position.target.latitude, _position.target.longitude);

    _add(_position.target);
  }

  void _findNameFromLatLng(double lat, double lng) async {
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    setState(() {
      _address = addresses.first;
    });
  }

  CameraPosition _currentLocation() {
    _findCurrentLocationName(widget.latitude, widget.longitude);

    return CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        //tilt: 59.440717697143555,
        zoom: 16.0);
  }

  void _findCurrentLocationName(double lat, double lng) async {
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    setState(() {
      _myCurrentAddress = addresses.first;
    });
  }

  CameraPosition _newPosition(LatLng pos) {
    _position = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: _zoom);
    return _position;
  }

  CameraPosition _newPositionSearch(double lat, double lng) {
    _position = CameraPosition(
        target: LatLng(lat, lng), 
zoom: 16.0);

    return _position;
  }

  Future<void> _findAddressesFromCoordinates(LatLng tapped) async {
    final coordinates = new Coordinates(tapped.latitude, tapped.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    setState(() {
      _address = addresses.first;
    });
  }

  void _add(LatLng pos) {
    final String markerIdVal = 'marker id';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        pos.latitude,
        pos.longitude,
      ),
      // infoWindow: InfoWindow(
      //     title: (_onMarkMoved!=null)?_address.countryName: _first.countryName,
      //     snippet: (_onMarkMoved!=null)?'${_address.adminArea} ${_address.addressLine}':'${_first.adminArea}${_first.addressLine}'),
    );
    selectedMarker = markerId;

    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<void> _saveLocationInSharedPrefs(
      Address address,
      Address myCurrentAddress,
      CameraPosition position,
      double latitude,
      double longitude) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      (address != null)
          ? _savePrefsForLocationSetManually(prefs, address, position)
          : _savePrefsForCurrentLocation(
              prefs, myCurrentAddress, latitude, longitude);
    });
  }

  void _savePrefsForLocationSetManually(
      SharedPreferences prefs, Address address, CameraPosition position) {
    prefs.setString(
        'myLocation', '${address.adminArea} ${address.addressLine}');
    prefs.setDouble('myLat', position.target.latitude);
    prefs.setDouble('myLng', position.target.longitude);
  }

  void _savePrefsForCurrentLocation(SharedPreferences prefs,
      Address myCurrentAddress, double latitude, double longitude) {
    prefs.setString("myLocation",
        '${myCurrentAddress.adminArea} ${myCurrentAddress.addressLine}');
    prefs.setDouble('myLat', latitude);
    prefs.setDouble('myLng', longitude);
  }
}
