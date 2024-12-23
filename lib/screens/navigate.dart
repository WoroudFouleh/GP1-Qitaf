// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:login_page/screens/map2.dart';
// import 'package:login_page/screens/map_screen.dart'; // Import your MapScreen file

// class SecondPage extends StatefulWidget {
//   @override
//   _SecondPageState createState() => _SecondPageState();
// }

// class _SecondPageState extends State<SecondPage> {
//   TextEditingController _locationController = TextEditingController();
//   TextEditingController _coordController = TextEditingController();
//   TextEditingController _inputCoordController = TextEditingController();

//   LatLng? locationCoordinates;

//   void _navigateToMap() async {
//     // Navigate to the MapScreen and wait for the result
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => MapScreen(),
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         _locationController.text = result['name']; // Fill the TextField
//         _coordController.text =
//             "${result['position'].latitude}, ${result['position'].longitude}";
//         locationCoordinates = result['position'];
//         print("Name: ${result['name']}, Coordinates: ${result['position']}");
//       });

//       // Optionally save the result to the database
//       //_saveLocationToDatabase(result['name'], result['position']);
//     }
//   }

//   void _showCoordinatesOnMap() {
//     // Parse the input from _inputCoordController
//     final input = _inputCoordController.text.split(',');
//     if (input.length == 2) {
//       try {
//         final latitude = double.parse(input[0].trim());
//         final longitude = double.parse(input[1].trim());

//         final coordinates = LatLng(latitude, longitude);

//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => MapScreen2(
//               initialLocation: coordinates,
//             ),
//           ),
//         );
//       } catch (e) {
//         // Show an error message if parsing fails
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid coordinates format')),
//         );
//       }
//     } else {
//       // Show an error message if the input format is incorrect
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Please enter coordinates in "lat, lng" format')),
//       );
//     }
//   }

//   Future<void> _saveLocationToDatabase(String name, LatLng coordinates) async {
//     // Replace this with your database code
//     print(
//         'Saving to database: Name: $name, Coordinates: ${coordinates.latitude}, ${coordinates.longitude}');
//     // Example: Using Firebase Firestore
//     // await FirebaseFirestore.instance.collection('locations').add({
//     //   'name': name,
//     //   'latitude': coordinates.latitude,
//     //   'longitude': coordinates.longitude,
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Second Page')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // TextField for displaying and editing location name
//               TextField(
//                 controller: _locationController,
//                 readOnly: true, // Makes it non-editable
//                 decoration: InputDecoration(
//                   labelText: 'Selected Location',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _coordController,
//                 readOnly: true, // Makes it non-editable
//                 decoration: InputDecoration(
//                   labelText: 'Selected Coordinates',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _navigateToMap,
//                 child: Text('Select Location from Map'),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _inputCoordController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter Coordinates (lat, lng)',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _showCoordinatesOnMap,
//                 child: Text('Show Coordinates on Map'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
