import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_page/screens/config.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/CartPage.dart';

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
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late String username;
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
        'location': addressController.text,
        'phoneNumber': phoneController.text,
        'totalPrice': widget.totalPrice,
        'items': widget.items, // The list of items
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 15, top: 20),
          alignment: Alignment.centerRight,
          child: const Text(
            "قم بتعبئة تفاصيل الطلب",
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF355E3B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 370,
          child: TextFormField(
            controller: addressController,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: " العنوان",
              hintStyle: TextStyle(
                fontSize: 20,
                color: Color(0xFF355E3B),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15, top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 370,
          child: TextFormField(
            controller: phoneController,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "رقم الهاتف",
              hintStyle: TextStyle(
                fontSize: 20,
                color: Color(0xFF355E3B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.only(right: 15, bottom: 10),
          alignment: Alignment.centerRight,
          child: const Text(
            "طريقة الدفع",
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF355E3B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        paymentOptionContainer(
          context,
          icon: Icons.attach_money,
          title: "الدفع عند الاستلام",
          value: 'cash',
        ),
        paymentOptionContainer(
          context,
          imagePath: 'assets/images/visa.png',
          title: "فيزا ** ** ** 2187",
          value: 'visa',
        ),
        const SizedBox(height: 50),
        InkWell(
          onTap: () {
            if (selectedPaymentMethod == 'visa') {
              _showCardDetailsBottomSheet(context);
            } else {
              makeOrder();
              // تنفيذ عملية الطلب بالدفع عند الاستلام
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF355E3B),
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
        ),
        const SizedBox(height: 50),
      ],
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
