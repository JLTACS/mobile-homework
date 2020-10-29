import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMap extends StatefulWidget {
  HomeMap({Key key}) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  Set<Marker> _mapMarkers = Set();
  Set<Polygon> _mapPolygon = Set();
  GoogleMapController _mapController;
  bool first = true;
  TextEditingController _addressController = TextEditingController();
  Position _currentPosition;
  Position _defaultPosition = Position(
    longitude: 20.608148,
    latitude: -103.417576,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentPosition(),
      builder: (context, result) {
        if (result.error == null) {
          if (_currentPosition == null) _currentPosition = _defaultPosition;
          return Scaffold(
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  markers: _mapMarkers,
                  polygons: _mapPolygon,
                  onLongPress: _setMarker,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                  ),
                ),
               
                Positioned(
                      top: 50,
                      left: 20,
                      child: Container(
                        height: 100,
                        width: 320,
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Encuentra Dirección",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search), 
                              onPressed: () {
                                //print(_addressController.text);
                               _getLocationFromAddress(_addressController.toString());
                              }
                            )
                          ),
                        ),
                      ),
                    ),
                Positioned(
                  bottom: 90,
                  right: 10,
                  child: FloatingActionButton(
                    child: Icon(Icons.home),
                    onPressed: (){
                      _moveToHome();
                    }
                  )
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    child: Icon(Icons.square_foot),
                    onPressed: (){
                      _setPolygon();
                    }
                  )
                ),
              ],
            ),
          );
        } else {
          Scaffold(
            body: Center(child: Text("Error!")),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _onMapCreated(controller) {
    setState(() {
      _mapController = controller;
      _moveToHome();
    });
  }

  void _setMarker(LatLng coord) async {
    // get address
    Placemark _markerAddress = await _getGeolocationAddress(
      Position(latitude: coord.latitude, longitude: coord.longitude),
    );

    // add marker
    setState(() {
      _mapMarkers.add(
        Marker(
          markerId: MarkerId(coord.toString()),
          position: coord,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onTap: () => _settingModalBottomSheet(context, _markerAddress),
        ),
      );
    });
  }

  void _setPolygon() async {
    List<LatLng> positions =  _mapMarkers.map((m){return m.position;}).toList();
    _mapPolygon.clear();
    setState(() {
      _mapPolygon.add(
        Polygon(
          polygonId: PolygonId("unique"),
          points: positions,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.15)
        )
      );
      print(_mapPolygon.first.polygonId);
    });
  }

  Future<void> _getCurrentPosition() async {
    // get current position
  
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // get address
    Placemark _currentAddress = await _getGeolocationAddress(_currentPosition);

    if(first) {
        _mapMarkers.add(
        Marker(
          markerId: MarkerId(_currentPosition.toString()),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          onTap: () => _settingModalBottomSheet(context, _currentAddress),
        ),
      );

      first = false;
    }
    // add marker
    
  }

  void _moveToHome() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<Placemark> _getGeolocationAddress(Position position) async {
    var places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    
    if (places != null && places.isNotEmpty) {
      final Placemark place = places.first;
      return place;
    }
    return null;
  }

  Future<void> _getLocationFromAddress(String address) async {
    try{
      List<Location> locations = await locationFromAddress(address);

      // move camera
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              locations[0].latitude,
              locations[0].longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    } catch(e) {
      print("Error");
    }
  }

  void _settingModalBottomSheet(context, Placemark place){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: new Wrap(
            children: <Widget>[
              new ListTile(
                title: new Text(place.thoroughfare + ' ' + place.subThoroughfare + ', ' + place.subLocality),
                onTap: () => {}          
              ),
              new ListTile(
                title: new Text(place.locality + ', ' + place.administrativeArea + '. ' + place.country),
                onTap: () => {},          
              ),
              new ListTile(
                title: new Text('C.P. ' + place.postalCode),
                onTap: () => {},          
              ),
            ],
          ),
        );
      }
    );
  }
}
