import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title for Pie Chart 1
          Text(
            'نسبة الأراضي المعروضة حسب المدن',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Pie Chart 1: أرض معروضة حسب المدن
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: PieChart(_buildPieChartData([
              {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
              {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
              {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
              {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
            ])),
          ),
          SizedBox(height: 24),

          // Title for Pie Chart 2
          Text(
            'نسبة خطوط الإنتاج حسب المدن',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Pie Chart 2: خطوط الإنتاج حسب المدن
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: PieChart(_buildPieChartData([
              {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
              {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
              {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
              {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
            ])),
          ),
          SizedBox(height: 24),

          // Title for Pie Chart 3
          Text(
            'نسبة المستخدمين حسب المدن',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Pie Chart 3: المستخدمين حسب المدن
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: PieChart(_buildPieChartData([
              {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
              {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
              {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
              {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
            ])),
          ),
          SizedBox(height: 16),

          // Color Legend for Pie Chart 4
          Row(
            children: [
              _colorBox(Colors.purple, ' نابلس'),
              _colorBox(Colors.blue, 'رام الله'),
              _colorBox(Colors.orange, 'جنين'),
              _colorBox(Colors.green, 'طولكرم'),
            ],
          ),
          SizedBox(height: 24),

          // Title for Pie Chart 4
          Text(
            'نسبة المنتجات (غذائية / غير غذائية / محاصيل)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16),
          // Pie Chart 4: المنتجات حسب الفئة
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: PieChart(_buildPieChartData([
              {'name': 'منتجات غذائية', 'value': 50.0, 'color': Colors.green},
              {'name': 'منتجات غير غذائية', 'value': 30.0, 'color': Colors.red},
              {'name': 'محاصيل', 'value': 20.0, 'color': Colors.yellow},
            ])),
          ),
          SizedBox(height: 16),

          // Color Legend for Pie Chart 4
          Row(
            children: [
              _colorBox(Colors.green, ' غذائية'),
              _colorBox(Colors.red, ' غير غذائية'),
              _colorBox(Colors.yellow, 'محاصيل'),
            ],
          ),
          SizedBox(height: 24),

          // القسم الثاني: أهم العناصر
          const Text(
            'أهم العناصر',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/images/p1.jpg'), // استخدام الأصول هنا
              ),
              title: Text(
                'الأكثر اهتماماً: قطف الأراضي',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  Text('مدينة نابلس'),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/images/q1.jpg'), // استخدام الأصول هنا
              ),
              title: Text(
                'أفضل منتج: زيت الزيتون',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange),
                  Text('تقييم: 4.8'),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/images/a1.jpg'), // استخدام الأصول هنا
              ),
              title: Text(
                'الأكثر مبيعاً: صابون نابلس',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue),
                  Text('تم بيع 5000 قطعة'),
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/images/r1.jpg'), // استخدام الأصول هنا
              ),
              title: Text(
                'خط الإنتاج الأكثر طلباً: معاصر الزيتون',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.factory, color: Colors.red),
                  Text('عدد الطلبات: 120'),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // القسم الثالث: الأرقام الإجمالية
          Text(
            'الأرقام الإجمالية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('المستخدمين', '120', Icons.people),
              _buildStatCard('المالكين', '45', Icons.person_outline),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('رجال التوصيل', '25', Icons.delivery_dining),
              _buildStatCard('الأراضي المعروضة', '340', Icons.landscape),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('المنتجات', '85', Icons.shopping_bag),
              _buildStatCard('خطوط الإنتاج', '12', Icons.factory),
            ],
          ),
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(List<Map<String, dynamic>> data) {
    return PieChartData(
      sections: data
          .map((item) => PieChartSectionData(
                value: item['value'].toDouble(),
                color: item['color'],
                title: '${item['value']}%',
                titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ))
          .toList(),
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    );
  }

  Widget _colorBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

PieChartData _buildPieChartData(List<Map<String, dynamic>> data) {
  return PieChartData(
    sections: data
        .map((item) => PieChartSectionData(
              value: item['value'].toDouble(), // Convert int to double
              color: item['color'],
              title: '${item['value']}%',
              titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ))
        .toList(),
    centerSpaceRadius: 40,
    sectionsSpace: 2,
  );
}

Widget _buildStatCard(String title, String count, IconData icon) {
  return Expanded(
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 40),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}
