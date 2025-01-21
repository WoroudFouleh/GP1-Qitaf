import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:login_page/screens/config.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Map<String, dynamic>> pieChartData = [];
  List<Map<String, dynamic>> productionLinesCities = [];
  List<Map<String, dynamic>> productsCategories = [];
  List<Map<String, dynamic>> usersCities = [];
  Map<String, dynamic> overallStats = {};
  Color getColorForCity(String city) {
    switch (city) {
      case 'القدس':
        return Colors.yellow;
      case 'بيت لحم':
        return Colors.blue;
      case 'طوباس':
        return Colors.green;
      case 'رام الله':
        return Colors.amber;
      case 'نابلس':
        return Colors.purple;
      case 'الخليل':
        return Colors.orange;
      case 'جنين':
        return Colors.red;
      case 'طولكرم':
        return Colors.pink;
      case 'قلقيلية':
        return Colors.brown;
      case 'سلفيت':
        return Colors.cyan;
      case 'أريحا':
        return Colors.indigo;
      case ' غزة':
        return Colors.teal;
      case 'دير البلح':
        return Colors.grey;
      case 'خان يونس':
        return Colors.lightBlue;
      case ' رفح':
        return Colors.deepPurple;
      case 'الداخل الفلسطيني ':
        return Colors.deepOrange;
      default:
        return Colors.grey; // Fallback color if the city is not recognized
    }
  }

  Future<void> fetchOverallStatistics() async {
    try {
      final response = await http.get(Uri.parse(getAllStatistic));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          overallStats = data;
        });
      } else {
        throw Exception('Failed to fetch overall statistics');
      }
    } catch (error) {
      print('Error fetching statistics: $error');
    }
  }

  Future<void> fetchLandsByCity() async {
    try {
      final response = await http.get(Uri.parse(getLandStatistic));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pieChartData = data
              .map<Map<String, dynamic>>((item) => {
                    'name': item['city'],
                    'value': item['percentage'],
                    'color': getColorForCity(item['city']),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchUsersByCity() async {
    try {
      final response = await http.get(Uri.parse(getUserStatistic));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usersCities = data
              .map<Map<String, dynamic>>((item) => {
                    'name': item['city'],
                    'value': item['percentage'],
                    'color': getColorForCity(item['city']),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchProductionLinesByCity() async {
    try {
      final response = await http.get(Uri.parse(getLineStatistic));
      if (response.statusCode == 200) {
        print("200ss");
        final data = jsonDecode(response.body);
        setState(() {
          productionLinesCities = data
              .map<Map<String, dynamic>>((item) => {
                    'name': item['city'],
                    'value': item['percentage'],
                    'color': getColorForCity(item['city']),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load production');
      }
    } catch (error) {
      print('Error fetching lines: $error');
    }
  }

  Future<void> fetchProductCategories() async {
    try {
      final response = await http.get(Uri.parse(getProducStatistic));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          productsCategories = data
              .map<Map<String, dynamic>>((item) => {
                    'name': item[
                        'category'], // Category name (محصول, غذائي, غير غذائي)
                    'value': item['percentage'], // Percentage value
                    'color': getColorForCategory(item['category']),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load product categories');
      }
    } catch (error) {
      print('Error fetching product categories: $error');
    }
  }

  Color getColorForCategory(String category) {
    switch (category) {
      case 'منتج غذائي':
        return Colors.green;
      case 'منتج غير غذائي':
        return Colors.red;
      case 'محصول':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLandsByCity();
    fetchProductionLinesByCity();
    fetchProductCategories();
    fetchUsersByCity();
    fetchOverallStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('نسبة الأراضي المعروضة حسب المدن'),
          _buildPieChartContainer(pieChartData.isEmpty
              ? [
                  {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
                  {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
                  {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
                  {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
                ]
              : pieChartData),
          SizedBox(height: 24),
          _buildSectionTitle('نسبة خطوط الإنتاج حسب المدن'),
          _buildPieChartContainer(productionLinesCities.isEmpty
              ? [
                  {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
                  {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
                  {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
                  {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
                ]
              : productionLinesCities),
          SizedBox(height: 24),
          _buildSectionTitle('نسبة المستخدمين حسب المدن'),
          _buildPieChartContainer(usersCities.isEmpty
              ? [
                  {'name': 'نابلس', 'value': 40.0, 'color': Colors.purple},
                  {'name': 'رام الله', 'value': 25.0, 'color': Colors.blue},
                  {'name': 'جنين', 'value': 15.0, 'color': Colors.orange},
                  {'name': 'طولكرم', 'value': 20.0, 'color': Colors.green},
                ]
              : usersCities),
          SizedBox(height: 24),
          _buildSectionTitle('نسبة المنتجات (غذائي / غير غذائي / محصول)'),
          _buildPieChartContainer(productsCategories),
          SizedBox(height: 24),
          // _buildSectionTitle(' القسم الأكثر ارتياداً'),
          // _buildFeatureCard(
          //   image: 'assets/images/p1.jpg',
          //   title: 'الأكثر اهتماماً: قطف الأراضي',
          //   subtitle: 'مدينة نابلس',
          //   icon: Icons.location_on,
          //   iconColor: Colors.green,
          // ),
          SizedBox(height: 24),
          _buildSectionTitle('الأرقام الإجمالية'),
          SizedBox(height: 24),
          _buildStatRow([
            {
              'title': 'المستخدمين',
              'count': overallStats['users']?.toString() ?? '0',
              'icon': Icons.people
            },
            {
              'title': 'المالكين',
              'count': overallStats['landowners']?.toString() ?? '0',
              'icon': Icons.person_outline
            },
          ]),
          _buildStatRow([
            {
              'title': 'رجال التوصيل',
              'count': overallStats['deliveryMen']?.toString() ?? '0',
              'icon': Icons.delivery_dining
            },
            {
              'title': 'الأراضي المعروضة',
              'count': overallStats['lands']?.toString() ?? '0',
              'icon': Icons.landscape
            },
          ]),
          _buildStatRow([
            {
              'title': 'المنتجات',
              'count': overallStats['products']?.toString() ?? '0',
              'icon': Icons.shopping_bag
            },
            {
              'title': 'خطوط الإنتاج',
              'count': overallStats['productionLines']?.toString() ?? '0',
              'icon': Icons.factory
            },
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPieChartContainer(List<Map<String, dynamic>> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: Container(
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
            child: PieChart(_buildPieChartData(data)),
          ),
        ),
        SizedBox(width: 16),
        // City-Color Catalog
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((item) {
              return Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: item['color'],
                  ),
                  SizedBox(width: 8),
                  Text(
                    item['name'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  PieChartData _buildPieChartData(List<Map<String, dynamic>> data) {
    return PieChartData(
      sections: data
          .map((item) => PieChartSectionData(
                value: item['value'].toDouble(),
                color: item['color'],
                title: '${item['value'].toStringAsFixed(2)}%',
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ))
          .toList(),
      centerSpaceRadius: 40,
      sectionsSpace: 2,
    );
  }

  Widget _buildColorLegend(List<Map<String, dynamic>> legends) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: legends
          .map((legend) => Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: legend['color'],
                  ),
                  SizedBox(width: 8),
                  Text(legend['label'], style: TextStyle(fontSize: 16)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildFeatureCard({
    required String image,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(List<Map<String, dynamic>> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats
          .map((stat) => Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Icon(stat['icon'], color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text(
                          stat['title'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          stat['count'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
