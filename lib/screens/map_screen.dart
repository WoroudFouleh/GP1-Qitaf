import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_service;
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart' as directions_service;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapScreen extends StatefulWidget {
  final LatLng?
      initialLocation; // Initial location passed from the previous page

  MapScreen({this.initialLocation});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final location_service.Location _location = location_service.Location();
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Map<String, LatLng> _customLocations =
      {}; // لتخزين المواقع المضافة يدويًا
  bool _isLoading = false;

  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAnyO6dwaSxhkal_COd59PbwYUg8z6hvu0');
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
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى تفعيل خدمة الموقع')),
        );
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location_service.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location_service.PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفض إذن الموقع')),
        );
        return;
      }
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
  }

  Future<void> _searchLocation(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحقق إذا كان الموقع موجودًا في القائمة المخصصة
      if (_customLocations.containsKey(query)) {
        final LatLng location = _customLocations[query]!;
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(location, 14.0),
        );
        return;
      }

      // إذا لم يكن الموقع مخصصًا، قم بالبحث باستخدام API
      PlacesSearchResponse response = await _places.searchByText(query);
      if (response.status == "OK" && response.results.isNotEmpty) {
        final result = response.results.first;
        LatLng searchedLocation = LatLng(
          result.geometry!.location.lat,
          result.geometry!.location.lng,
        );

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(searchedLocation, 14.0),
        );

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(searchedLocation.toString()),
              position: searchedLocation,
              infoWindow: InfoWindow(title: query),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على نتائج')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء البحث: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getRoute(LatLng destination) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الموقع الحالي غير متاح')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      directions_service.DirectionsResponse response =
          await _directions.directionsWithLocation(
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
              color: const Color.fromARGB(255, 101, 147, 16),
              width: 5,
            ),
          );
        });

        // عرض نافذة التنبيه بالمعلومات
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Directionality(
              textDirection: TextDirection.rtl, // كتابة من اليمين إلى اليسار
              child: AlertDialog(
                title: Text(
                  'معلومات المسار',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 94, 143, 25), // اللون زيتي
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: const Color.fromARGB(
                                255, 83, 128, 27)), // أيقونة الوقت
                        SizedBox(width: 8),
                        Text(
                          'الوقت المقدر للوصول: $duration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.map_outlined,
                            color: const Color.fromARGB(
                                255, 75, 113, 24)), // أيقونة المسافة
                        SizedBox(width: 8),
                        Text(
                          'المسافة: $distance',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 3, 3, 3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Align(
                    alignment: Alignment.centerLeft, // زر الإغلاق إلى اليسار
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 85, 133, 14), // خلفية زيتي
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(
                          color: Colors.white, // الكتابة باللون الأبيض
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على مسار')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب المسار: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _getNewMarkerInfo(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Text('إضافة موقع جديد'),
              ],
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'اسم الموقع'),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(nameController.text),
                    child: Text(
                      'حفظ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Text('الخريطة', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final query = await showSearch(
                context: context,
                delegate: LocationSearchDelegate(_searchLocation),
              );
              if (query != null) {
                await _searchLocation(query);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.flag, color: Colors.white),
            onPressed: () async {
              if (_markers.isNotEmpty) {
                final destinationMarker = _markers.last.position;
                await _getRoute(destinationMarker);
              }
            },
          ),
        ],
        backgroundColor: Color(0xFF556B2F),
      ),
      body: Stack(
        children: [
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  onTap: (LatLng position) async {
                    String? name = await _getNewMarkerInfo(context);
                    if (name != null && name.isNotEmpty) {
                      setState(() {
                        _customLocations[name] = position;
                        _markers.add(
                          Marker(
                            markerId: MarkerId(position.toString()),
                            position: position,
                            infoWindow: InfoWindow(
                              title: name,
                              snippet: 'موقع مخصص',
                            ),
                          ),
                        );
                      });
                      Navigator.of(context)
                          .pop({'name': name, 'position': position});
                    }
                  },
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

class LocationSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  LocationSearchDelegate(this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListTile(
      title: Text('أدخل اسم المكان للبحث'),
    );
  }
}
