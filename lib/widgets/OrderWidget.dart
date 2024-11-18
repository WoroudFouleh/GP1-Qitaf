import 'package:flutter/material.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  String selectedPaymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 15, top: 20),
          alignment: Alignment.centerRight,
          child: Text(
            "قم بتعبئة تفاصيل الطلب",
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF355E3B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 15, top: 20),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 370,
          child: TextFormField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
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
          margin: EdgeInsets.only(left: 15, top: 20),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 370,
          child: TextFormField(
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "رقم الهاتف",
              hintStyle: TextStyle(
                fontSize: 20,
                color: Color(0xFF355E3B),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          margin: EdgeInsets.only(right: 15, bottom: 10),
          alignment: Alignment.centerRight,
          child: Text(
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
        SizedBox(height: 50),
        InkWell(
          onTap: () {
            if (selectedPaymentMethod == 'visa') {
              _showCardDetailsBottomSheet(context);
            } else {
              // تنفيذ عملية الطلب بالدفع عند الاستلام
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0xFF355E3B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "اطلب الآن",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
      ],
    );
  }

  Widget paymentOptionContainer(BuildContext context,
      {IconData? icon,
      String? imagePath,
      required String title,
      required String value}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
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
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF355E3B),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: Color(0xFF355E3B))
            : Image.asset(imagePath!, width: 40),
        leading: Radio<String>(
          value: value,
          groupValue: selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value!;
            });
          },
          activeColor: Color(0xFF355E3B),
        ),
      ),
    );
  }

  void _showCardDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStyledTextField("شهر الانتهاء")),
                  SizedBox(width: 10),
                  Expanded(child: _buildStyledTextField("سنة الانتهاء")),
                ],
              ),
              SizedBox(height: 10),
              _buildStyledTextField("رمز الأمان"),
              SizedBox(height: 10),
              _buildStyledTextField("الاسم الأول"),
              SizedBox(height: 10),
              _buildStyledTextField("اسم العائلة"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF355E3B),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'إضافة البطاقة',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 18, color: Color(0xFF355E3B)),
        filled: true,
        fillColor: Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
