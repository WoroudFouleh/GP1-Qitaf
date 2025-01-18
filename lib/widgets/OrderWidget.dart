import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/CartPage.dart';
import 'package:login_page/screens/map_screen.dart';

class OrderWidget extends StatefulWidget {
  final List<dynamic> items;
  final String token;

  final int totalPrice;

  const OrderWidget(
      {required this.items,
      required this.token,
      required this.totalPrice,
      Key? key})
      : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  String selectedPaymentMethod = 'cash';
  String selectedDeliveryMethod = 'slow';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late String username;
  String? selectedCity;
  LatLng? locationCoordinates;
  double deliveryPrice = 0;
  final List<String> cities = [
    'القدس',
    'بيت لحم',
    'طوباس',
    'رام الله',
    'نابلس',
    'الخليل',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'سلفيت',
    'أريحا',
    'غزة',
    'دير البلح',
    'خان يونس',
    'رفح',
    'الداخل الفلسطيني'
  ];
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);

    username = jwtDecoderToken['username'] ?? 'No First Name';
  }

  void makeOrder() async {
    if (addressController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تعبئة جميع الحقول المطلوبة")),
      );
      return;
    }

    try {
      // Prepare the order details
      final orderDetails = {
        'username': username,
        'recepientCity': selectedCity,
        'location': addressController.text,
        'phoneNumber': phoneController.text,
        'totalPrice': widget.totalPrice,
        'items': widget.items, // The list of items
        "coordinates": {
          "lat": locationCoordinates!.latitude,
          "lng": locationCoordinates!.longitude,
        },
        "deliveryType": selectedDeliveryMethod
      };

      // Send the request to your backend API
      final response = await http.post(
        Uri.parse(registerOrder), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderDetails),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الطلب بنجاح")),
        );
        updateQuantity();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء تسجيل الطلب")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  void updateQuantity() async {
    try {
      // Prepare the order details
      final cartItems = {
        'items': widget.items, // The list of items
      };

      // Send the request to your backend API
      final response = await http.post(
        Uri.parse(updateQuantities), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(cartItems),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تعديل الكميات بنجاح")),
        );
        clearUserCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء تعديل الطلب")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  void clearUserCart() async {
    try {
      // Prepare the order details

      // Send the request to your backend API
      final response = await http.delete(
        Uri.parse('$deleteUserCart/$username'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف السلة بنجاح")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(token: widget.token),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء حذف السلة")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  void _navigateToMap() async {
    // Navigate to the MapScreen and wait for the result
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        addressController.text = "${result['name']}"; // Fill the TextField
        // _coordController.text =
        //     "${result['position'].latitude}, ${result['position'].longitude}";
        locationCoordinates = result['position'];
        print("Name: ${result['name']}, Coordinates: ${result['position']}");
      });

      // Optionally save the result to the database
      //_saveLocationToDatabase(result['name'], result['position']);
    }
  }

  double calculateDeliveryPrice(String? destinationCity, bool isFastDelivery) {
    // Define the groups
    print(isFastDelivery);
    const westBankCities = [
      'بيت لحم',
      'طوباس',
      'رام الله',
      'نابلس',
      'الخليل',
      'جنين',
      'طولكرم',
      'قلقيلية',
      'سلفيت',
      'أريحا',
    ]; // Example cities
    const gazaCities = [
      'غزة',
      'دير البلح',
      'خان يونس',
      'رفح',
    ]; // Example cities
    const occupiedCities = ['الداخل الفلسطيني', 'القدس']; // Example cities

    // Helper function to identify city group
    String getCityGroup(String? city) {
      if (westBankCities.contains(city)) {
        return 'westbank';
      } else if (gazaCities.contains(city)) {
        return 'gaza';
      } else if (occupiedCities.contains(city)) {
        return 'occupied';
      } else {
        return 'unknown';
      }
    }

    // Get the city group for the destination city only
    String destinationGroup = getCityGroup(destinationCity);

    // Determine the delivery price based on the destination city
    double deliveryPrice = 0;

    if (destinationGroup == 'westbank' || destinationGroup == 'gaza') {
      deliveryPrice = 20; // Westbank or Gaza destination
    } else if (destinationGroup == 'occupied') {
      deliveryPrice = 40; // Occupied destination
    } else {
      deliveryPrice =
          40; // Default price for unknown destination (could be adjusted)
    }

    // If fast delivery is chosen, increase the price
    if (isFastDelivery) {
      deliveryPrice *= 1.5; // Increase by 50% for fast delivery
    }

    return deliveryPrice;
  }

  double calculateTotalPrice(double itemPrice, double deliveryPrice) {
    return itemPrice + deliveryPrice;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          _buildSectionHeader("قم بتعبئة تفاصيل الطلب"),
          _buildDropdown(
            context,
            label: "اختر مدينة الاستلام",
            value: selectedCity,
            items: cities,
            onChanged: (value) {
              setState(() {
                selectedCity = value;
                // Calculate the delivery price when the city changes
                deliveryPrice = calculateDeliveryPrice(
                    selectedCity, selectedDeliveryMethod == 'fast');
              });
            },
          ),
          const SizedBox(height: 15),
          _buildTextInput(
            label: "عنوان الاستلام",
            controller: addressController,
            icon: Icons.location_on,
            onIconPressed: _navigateToMap,
          ),
          const SizedBox(height: 15),
          _buildTextInput(
            label: "رقم الهاتف",
            controller: phoneController,
            icon: Icons.phone,
          ),
          _buildSectionHeader("طريقة التوصيل"),
          _buildDeliveryOptions(),
          _buildSectionHeader("طريقة الدفع"),
          _buildPaymentOptions(),
          const SizedBox(height: 20),
          _buildOrderSummary(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF355E3B),
        ),
        textAlign: TextAlign.right, // Align text to the right for Arabic
        textDirection:
            TextDirection.rtl, // Ensure text is properly aligned for RTL
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        items: items.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city, textAlign: TextAlign.right),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ),
          if (icon != null)
            IconButton(
              icon: Icon(icon, color: Colors.green),
              onPressed: onIconPressed,
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Column(
      children: [
        DeliveryOptionContainer(
          context,
          icon: Icons.fast_forward,
          title: "توصيل سريع",
          value: 'fast',
        ),
        DeliveryOptionContainer(
          context,
          icon: Icons.delivery_dining,
          title: "توصيل عادي - قطع منفردة",
          value: 'slow',
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    // Check if the selected delivery method is 'fast'
    bool isFastDelivery = selectedDeliveryMethod == 'fast';

    return Column(
      children: [
        // Show both payment options if delivery is fast
        if (isFastDelivery)
          paymentOptionContainer(
            context,
            icon: Icons.attach_money,
            title: "الدفع عند الاستلام",
            value: 'cash',
          ),
        if (isFastDelivery)
          paymentOptionContainer(
            context,
            imagePath: 'assets/images/visa.png',
            title: "فيزا ** ** ** 2187",
            value: 'visa',
          ),
        // Show only visa if delivery is slow
        if (!isFastDelivery)
          paymentOptionContainer(
            context,
            imagePath: 'assets/images/visa.png',
            title: "فيزا ** ** ** 2187",
            value: 'visa',
          ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    double totalPrice =
        calculateTotalPrice(widget.totalPrice.toDouble(), deliveryPrice);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
              label: ":الإجمالي الفرعي", value: widget.totalPrice.toString()),
          const Divider(),
          _buildSummaryRow(
              label: ":تكلفة التوصيل", value: deliveryPrice.toString()),
          const Divider(),
          // _buildSummaryRow(label: ":خصم", value: "-10"), // Example discount
          // const Divider(),
          _buildSummaryRow(
              label: ":الإجمالي",
              value: totalPrice
                  .toStringAsFixed(2), // Total price with two decimals
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.redAccent : Colors.black54,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: () {
        if (selectedPaymentMethod == 'visa') {
          _showCardDetailsBottomSheet(context);
        } else {
          makeOrder();
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "اطلب الآن",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget paymentOptionContainer(BuildContext context,
      {IconData? icon,
      String? imagePath,
      required String title,
      required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355E3B).withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF355E3B),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: const Color(0xFF355E3B))
            : Image.asset(imagePath!, width: 40),
        leading: Radio<String>(
          value: value,
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value!;
            });
          },
          activeColor: const Color(0xFF355E3B),
        ),
      ),
    );
  }

  Widget DeliveryOptionContainer(BuildContext context,
      {IconData? icon,
      String? imagePath,
      required String title,
      required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF355E3B).withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF355E3B),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: const Color(0xFF355E3B))
            : Image.asset(imagePath!, width: 40),
        leading: Radio<String>(
          value: value,
          groupValue: selectedDeliveryMethod,
          onChanged: (value) {
            setState(() {
              selectedDeliveryMethod = value!;
              deliveryPrice = calculateDeliveryPrice(
                  selectedCity, selectedDeliveryMethod == 'fast');
            });
          },
          activeColor: const Color(0xFF355E3B),
        ),
      ),
    );
  }

  void _showCardDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField("رقم البطاقة"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStyledTextField("شهر الانتهاء")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStyledTextField("سنة الانتهاء")),
                ],
              ),
              const SizedBox(height: 10),
              _buildStyledTextField("رمز الأمان"),
              const SizedBox(height: 10),
              _buildStyledTextField("الاسم الأول"),
              const SizedBox(height: 10),
              _buildStyledTextField("اسم العائلة"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355E3B),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'إضافة البطاقة',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField(String hint) {
    return TextField(
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 18, color: Color(0xFF355E3B)),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
