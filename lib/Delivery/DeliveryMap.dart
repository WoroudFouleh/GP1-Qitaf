import 'package:flutter/material.dart';

class Deliverymap extends StatefulWidget {
  @override
  _DeliveryMapState createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<Deliverymap> {
  bool _isDelivered = false; // حالة التوصيل

  void _markAsDelivered() {
    setState(() {
      _isDelivered = true; // تم التوصيل
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView.builder(
          itemCount: 1, // عدد الطلبات المقبولة (يمكن تعديل العدد حسب الحاجة)
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEFFAF1), // لون زيتي فاتح
                      Color(0xFFDFF2E0), // لون أبيض مخضر
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // رقم الطلب
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.blue),
                        Text(
                          'رقم الطلب: 12345',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    const Divider(thickness: 1.5),
                    // صورة في قسم منفصل
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green[100],
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    // التفاصيل مع الأيقونات الملونة
                    _buildOrderDetailWithIcon(Icons.account_circle, 'المالك',
                        'محمد خالد', Colors.brown),
                    _buildOrderDetailWithIcon(
                        Icons.phone, 'رقم المالك', '0597123456', Colors.orange),
                    _buildOrderDetailWithIcon(
                        Icons.person, 'الزبون', 'ورود فوله', Colors.purple),
                    _buildOrderDetailWithIcon(
                        Icons.phone, 'رقم الزبون', '0597280457', Colors.orange),
                    _buildOrderDetailWithIcon(Icons.location_on,
                        'عنوان التوصيل', 'شارع 24 نابلس', Colors.red),
                    _buildOrderDetailWithIcon(Icons.monetization_on, 'الدفع',
                        'عند الاستلام', Colors.teal),
                    _buildOrderDetailWithIcon(Icons.attach_money, 'السعر الكلي',
                        '39.60₪', Colors.blue),

                    const SizedBox(height: 8.0),

                    // زر تم التوصيل
                    _isDelivered
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 30,
                              ),
                              const SizedBox(width: 8.0),
                              const Text(
                                'تم التوصيل بنجاح',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: _markAsDelivered,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: Colors.blue[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                    color: Colors.blue.shade800, width: 1.5),
                              ),
                            ),
                            child: const Text(
                              'تم التوصيل',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetailWithIcon(
      IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // جهة البداية (يمين للعربية)
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
              textAlign: TextAlign.right, // المحاذاة النصية يمين
            ),
          ),
        ],
      ),
    );
  }
}
