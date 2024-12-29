import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_service;
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart' as directions_service;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen2 extends StatefulWidget {
  final LatLng?
      initialLocation; // Initial location passed from the previous page
  final String name;
  MapScreen2({this.initialLocation, required this.name});

  @override
  _MapScreen2State createState() => _MapScreen2State();
}

class _MapScreen2State extends State<MapScreen2> {
  final Completer<GoogleMapController> _controller = Completer();
  final location_service.Location _location = location_service.Location();
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = false;

  final directions_service.GoogleMapsDirections _directions =
      directions_service.GoogleMapsDirections(
          apiKey: 'AIzaSyAnyO6dwaSxhkal_COd59PbwYUg8z6hvu0');

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    location_service.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location_service.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location_service.PermissionStatus.granted)
        return;
    }

    location_service.LocationData locationData = await _location.getLocation();
    setState(() {
      _currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'موقعك الحالي'),
        ),
      );
    });

    // If an initial location is provided, focus on it and draw the route
    if (widget.initialLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('initial_location'),
          position: widget.initialLocation!,
          infoWindow: InfoWindow(title: widget.name),
        ),
      );
      _focusAndDrawRoute(widget.initialLocation!);
    }
  }

  Future<void> _focusAndDrawRoute(LatLng targetLocation) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(targetLocation, 14.0),
    );

    // Calculate and draw the route
    if (_currentPosition != null) {
      await _getRoute(targetLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location is not available')),
      );
    }
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _directions.directionsWithLocation(
        directions_service.Location(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        ),
        directions_service.Location(
          lat: destination.latitude,
          lng: destination.longitude,
        ),
        travelMode: directions_service.TravelMode.driving,
      );

      if (response.status == "OK" && response.routes.isNotEmpty) {
        final polylinePoints = PolylinePoints();
        final decodedPoints = polylinePoints.decodePolyline(
          response.routes.first.overviewPolyline.points,
        );

        final duration = response.routes.first.legs.first.duration.text;
        final distance = response.routes.first.legs.first.distance.text;

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: decodedPoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
              color: Color(0xFF556B2F),
              width: 5,
            ),
          );
        });

        // Display route information
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0), // لجعل الزوايا مستديرة
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end, // العنوان إلى اليمين
                children: [
                  Text(
                    'معلومات الطريق',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.directions,
                      color: Color(0xFF556B2F)), // أيقونة العنوان
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.end, // النص يبدأ من اليمين
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // الأيقونة إلى اليمين
                    children: [
                      Expanded(
                        child: Text(
                          ':الوقت المقدر للوصول',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.timer,
                          color: Color(0xFF556B2F)), // أيقونة الوقت
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // النص على اليمين
                    children: [
                      Expanded(
                        child: Text(
                          '$duration',
                          textAlign: TextAlign.right,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // الأيقونة إلى اليمين
                    children: [
                      Expanded(
                        child: Text(
                          ':االمسافة',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.map,
                          color: Color(0xFF556B2F)), // أيقونة المسافة
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // النص على اليمين
                    children: [
                      Expanded(
                        child: Text(
                          '$distance',
                          textAlign: TextAlign.right,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween, // ترتيب الأزرار
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color(0xFF556B2F)), // لون الزر أخضر
                    foregroundColor: MaterialStateProperty.all(
                        Colors.white), // لون النص أبيض
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 18), // أيقونة الإغلاق
                      SizedBox(width: 4),
                      Text('إغلاق'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No route found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch the route: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight, // Align text to the right
          child: Text(
            'الخريطة',
            style: TextStyle(
              color: Colors.white, // Set text color to white
            ),
          ),
        ),
        backgroundColor: Color(0xFF556B2F),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? LatLng(0, 0),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
