import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryRequestsPage extends StatefulWidget {
  const DeliveryRequestsPage({super.key});

  @override
  State<DeliveryRequestsPage> createState() => _DeliveryRequestsPageState();
}

class _DeliveryRequestsPageState extends State<DeliveryRequestsPage> {
  final Uri pdfUri = Uri.parse(
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'); // رابط لملف PDF

  // فتح ملف PDF
  Future<void> _openPDF(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // لفتح الملف في التطبيق الافتراضي
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن فتح الملف.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // بناء طلب فردي
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
                Icon(Icons.description, color: Colors.blue),
                Text(
                  'رقم الطلب: 98765',
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            _buildOrderDetailWithIcon(
                Icons.account_circle, 'الاسم', 'أحمد يوسف', Colors.brown),
            _buildOrderDetailWithIcon(Icons.email, 'البريد الإلكتروني',
                'ahmed@example.com', Colors.teal),
            _buildOrderDetailWithIcon(
                Icons.phone, 'رقم الجوال', '0597123456', Colors.orange),
            _buildOrderDetailWithIcon(
                Icons.location_city, 'المدينة', 'رام الله', Colors.blue),
            _buildOrderDetailWithIcon(Icons.calendar_today, 'تاريخ الميلاد',
                '1990-06-15', Colors.red),
            _buildOrderDetailWithIcon(
                Icons.timeline, 'العمر', 'سنة 45 ', Colors.purpleAccent),
            _buildOrderDetailWithIcon(Icons.card_membership, 'رقم الهوية',
                '123456789', Colors.purple), // إضافة حقل رقم الهوية
            _buildOrderDetailWithIcon(
                Icons.attach_file, ' رخصة القيادة', 'عرض الملف', Colors.green,
                isFile: true),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showAcceptDialog(); // عرض نافذة تأكيد القبول
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

  // إنشاء عنصر تفاصيل الطلب مع أيقونة
  Widget _buildOrderDetailWithIcon(
      IconData icon, String title, String value, Color color,
      {bool isFile = false}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: isFile
              ? TextButton.icon(
                  onPressed: () => _openPDF(pdfUri), // افتح الملف
                  icon: const Icon(Icons.file_open, color: Colors.green),
                  label: Text(
                    value,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // عرض نافذة تأكيد القبول
  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'إرسال رسالة قبول عبر SMS',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration:
                          const InputDecoration(labelText: 'اسم المستخدم'),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Logic to generate username can be added here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم توليد اسم المستخدم.'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration:
                          const InputDecoration(labelText: 'كلمة المرور'),
                      obscureText: true,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Logic to generate password can be added here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم توليد كلمة المرور.'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال رسالة القبول عبر SMS!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop(); // إغلاق النافذة
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'إرسال',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
        title: const Text(
          'طلبات التوصيل',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF556B2F),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white), // السهم الأبيض
          onPressed: () {
            Navigator.pop(context); // الرجوع إلى الصفحة السابقة
          },
        ),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => _buildOrderCard(),
      ),
    );
  }
}
