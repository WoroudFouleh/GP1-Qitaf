import 'package:flutter/material.dart';
import 'package:login_page/Delivery/AcceptedPage.dart';
import 'package:login_page/Delivery/DeliveryMap.dart';
import 'package:login_page/Delivery/DileveryProfile.dart';

class DeliveryOrdersPage extends StatefulWidget {
  @override
  _DeliveryOrdersPageState createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage> {
  String _status = 'متاح'; // الحالة الافتراضية
  int _currentIndex = 0;

  void _updateStatus(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  // صفحة رئيسية مع الحالة
  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'الحالة: $_status',
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusButton('متاح', _status == 'متاح', Colors.green[800]!),
              const SizedBox(width: 8.0),
              _buildStatusButton('مشغول', _status == 'مشغول', Colors.orange),
              const SizedBox(width: 8.0),
              _buildStatusButton(
                  'خارج عن الخدمة', _status == 'خارج عن الخدمة', Colors.red),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: _status == 'متاح'
              ? ListView.builder(
                  itemCount: 1, // عدد الطلبات
                  itemBuilder: (context, index) {
                    return _buildOrderCard();
                  },
                )
              : Center(
                  child: Text(
                    _status == 'مشغول'
                        ? 'لا توجد طلبات مخصصة لك حاليًا'
                        : 'أنت خارج عن الخدمة حاليًا',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildOrderCard() {
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
              Color(0xFFEFFAF1),
              Color(0xFFDFF2E0),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
            _buildOrderDetailWithIcon(
                Icons.account_circle, 'المالك', 'محمد خالد', Colors.brown),
            _buildOrderDetailWithIcon(
                Icons.phone, 'رقم المالك', '0597123456', Colors.orange),
            _buildOrderDetailWithIcon(
                Icons.person, 'الزبون', 'ورود فوله', Colors.purple),
            _buildOrderDetailWithIcon(
                Icons.phone, 'رقم الزبون', '0597280457', Colors.orange),
            _buildOrderDetailWithIcon(Icons.location_on, 'عنوان التوصيل',
                'شارع 24 نابلس', Colors.red),
            _buildOrderDetailWithIcon(
                Icons.monetization_on, 'الدفع', 'عند الاستلام', Colors.teal),
            _buildOrderDetailWithIcon(
                Icons.attach_money, 'السعر الكلي', '39.60₪', Colors.blue),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateStatus('مشغول');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                            color: Colors.green.shade800, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'قبول',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم رفض الطلب.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side:
                            BorderSide(color: Colors.red.shade800, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'رفض',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailWithIcon(
      IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, bool isSelected, Color color) {
    return ElevatedButton(
      onPressed: () => _updateStatus(status),
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected ? color : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 30.0),
        minimumSize: Size(100, 50),
      ),
      child: Text(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _currentIndex == 2
            ? null // لا يظهر التوب بار عند الضغط على الخريطة
            : AppBar(
                backgroundColor: Colors.green[800],
                title: Text(
                  _currentIndex == 0
                      ? 'الصفحة الرئيسية'
                      : _currentIndex == 1
                          ? 'الطلبات المقبولة'
                          : _currentIndex == 2
                              ? 'الخريطة'
                              : 'الملف الشخصي',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // تنفيذ عند الضغط على الجرس
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      // تنفيذ عند الضغط على تسجيل الخروج
                    },
                    color: Colors.white,
                  ),
                ],
              ),
        body: _currentIndex == 0
            ? _buildHomePage()
            : _currentIndex == 1
                ? AcceptedOrdersPage()
                : _currentIndex == 2
                    ? Deliverymap()
                    : DeliveryProfile(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'الخريطة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
