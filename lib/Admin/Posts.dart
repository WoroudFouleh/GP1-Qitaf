import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'package:login_page/screens/config.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> lands = [];
  List<dynamic> lines = [];
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // ثلاث تبويبات: أراضي، منتجات، خطوط إنتاج
    fetchLands();
    fetchLines();
    fetchProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchLines() async {
    final response = await http.get(
      Uri.parse('$getAllLines'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lines = data['lines']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  void fetchLands() async {
    final response = await http.get(
      Uri.parse('$getAllLands'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          lands = data['lands']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  void fetchProducts() async {
    final response = await http.get(
      Uri.parse('$getAllProducts'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products =
              data['products']; // Update the lands list with the response data
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // إزالة زر الرجوع
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(0), // لا توجد مساحة إضافية تحت التبويبات
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'أراضي'),
              Tab(text: 'منتجات'),
              Tab(text: 'خطوط إنتاج'),
            ],
            indicatorColor:
                const Color.fromRGBO(15, 99, 43, 1), // لون المؤشر زيتي
            labelColor:
                const Color.fromRGBO(15, 99, 43, 1), // لون النص المحدد زيتي
            unselectedLabelColor: Colors.black, // لون النص غير المحدد أسود
          ),
        ),
        elevation: 0, // إزالة الظل من شريط التطبيق
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LandsScreen(
              lands:
                  lands), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "أراضي"
          ProductsScreen(
              products:
                  products), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "منتجات"
          ProductionLinesScreen(
            productionLines: lines,
          ), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "خطوط إنتاج"
        ],
      ),
    );
  }
}

class LandsScreen extends StatefulWidget {
  final List<dynamic> lands; // Lands data from the API

  const LandsScreen({Key? key, required this.lands}) : super(key: key);

  @override
  _LandsScreenState createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  String? selectedCity; // Selected city for filtering
  List<dynamic> filteredLands = []; // Filtered list based on city

  @override
  void initState() {
    super.initState();
    filteredLands = widget.lands; // Initialize with all lands
  }

  void filterLandsByCity(String? city) {
    if (city == null) {
      setState(() {
        filteredLands = widget.lands; // Show all lands if no city is selected
      });
    } else {
      setState(() {
        filteredLands = widget.lands
            .where((land) => land['city'] == city) // Match city in the data
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Dropdown for city filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'اختر المدينة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedCity,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text("كل المدن"), // Option for all cities
                        ),
                        ...widget.lands
                            .map<String>((land) => land['city'] as String)
                            .toSet()
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ))
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                          filterLandsByCity(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLands.length,
                itemBuilder: (context, index) {
                  final land = filteredLands[index];
                  return Container(
                    padding: const EdgeInsets.only(top: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(15, 99, 43, 1)
                              .withOpacity(0.6),
                          spreadRadius: 2,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Land image
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromRGBO(15, 99, 43, 1),
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image:
                                      MemoryImage(base64Decode(land['image'])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Land details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    land['landName'] ?? "اسم الأرض",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromRGBO(15, 99, 43, 1),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 5),
                                      Text(
                                        land['username'] ?? "اسم صاحب الأرض",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${land['city'] ?? 'المدينة'} - ${land['location'] ?? 'الموقع'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.square_foot,
                                          color: const Color.fromRGBO(
                                              15, 99, 43, 1),
                                          size: 20),
                                      const SizedBox(width: 5),
                                      Text(
                                        "المساحة: ${land['landSpace'] ?? 'غير محدد'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        color: Colors.purple, // لون بنفسجي
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "عدد العمال: ${land['numOfWorkers']}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Colors.orange, // لون برتقالي
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "السعر: ₪ ${land['workerWages']} / لكل ساعة",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Colors.teal, // لون تركوازي
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "${land['startDate'].toString().substring(0, 10)}  - ${land['endDate'].toString().substring(0, 10)}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.pink, // لون وردي
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "ساعات العمل: ${land['startTime']} ص - ${land['endTime']} م",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.apple_rounded,
                                        color: Colors.brown, // لون بني
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "ثمار ${land['cropType']}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  final List<dynamic> products; // Pass products from parent widget

  ProductsScreen({required this.products});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategory;

  final List<String> categories = ["محصول", "منتج غذائي", "منتج غير غذائي"];

  List<dynamic> get filteredProducts {
    if (selectedCategory == null) {
      return widget.products;
    }
    return widget.products
        .where((product) => product['type'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'اختر الصنف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(15, 99, 43, 1)
                              .withOpacity(0.6),
                          spreadRadius: 2,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF556B2F),
                              width: 2,
                            ),
                            image: DecorationImage(
                              image:
                                  MemoryImage(base64Decode(product['image'])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? "اسم المنتج",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(15, 99, 43, 1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              buildRowWithIcon(Icons.star,
                                  "التقييم: ${product['rate'] ?? 'غير متوفر'}",
                                  color: Colors.amber),
                              buildRowWithIcon(Icons.inventory,
                                  "الكمية: ${product['quantity'] ?? 'غير متوفر'} ${product['quantityType']}",
                                  color: Colors.blue),
                              buildRowWithIcon(Icons.attach_money,
                                  "السعر: ₪ ${product['price'] ?? 'غير متوفر'} / لكل ${product['quantityType']}",
                                  color: Colors.green),
                              buildRowWithIcon(Icons.description,
                                  "الوصف: ${product['description'] ?? 'غير متوفر'}",
                                  color: Colors.purple),
                              buildRowWithIcon(Icons.timer,
                                  "مدة جهوز الطلب: ${product['preparationTime'] ?? 'غير متوفر'} ${product['preparationTimeUnit']}",
                                  color: Colors.red),
                              buildRowWithIcon(Icons.person,
                                  "اسم صاحب الأرض: ${product['username'] ?? 'غير متوفر'}",
                                  color: Colors.teal),
                              buildRowWithIcon(Icons.date_range,
                                  "تاريخ النشر: ${product['publishingDate'].toString().substring(0, 10) ?? 'غير متوفر'}",
                                  color: Colors.orange),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRowWithIcon(IconData icon, String text,
      {Color color = Colors.black}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}

// دالة لبناء صف يحتوي على أيقونة ونص مع لون مخصص للأيقونة
Widget buildRowWithIcon(IconData icon, String text, {required Color color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}

class ProductionLinesScreen extends StatefulWidget {
  final List<dynamic> productionLines; // Pass production lines dynamically

  ProductionLinesScreen({required this.productionLines});

  @override
  _ProductionLinesScreenState createState() => _ProductionLinesScreenState();
}

class _ProductionLinesScreenState extends State<ProductionLinesScreen> {
  String? selectedCity;

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

  // Filtered production lines based on selected city
  List<dynamic> get filteredProductionLines {
    if (selectedCity == null) return widget.productionLines;
    return widget.productionLines
        .where((line) => line['city'] == selectedCity)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // City Filter Dropdown
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'اختر المدينة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedCity,
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProductionLines.length,
                itemBuilder: (context, index) {
                  final line = filteredProductionLines[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(15, 99, 43, 1)
                              .withOpacity(0.6),
                          spreadRadius: 2,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular Image
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromRGBO(15, 99, 43, 1),
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: MemoryImage(base64Decode(line['image'])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line['lineName'] ?? "اسم خط الإنتاج",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(15, 99, 43, 1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              buildRowWithIcon(Icons.star,
                                  "التقييم: ${line['rate'] ?? 'غير متوفر'}",
                                  color: Colors.amber),
                              buildRowWithIcon(Icons.description,
                                  "الوصف: ${line['description'] ?? 'غير متوفر'}",
                                  color: Colors.blue),
                              buildRowWithIcon(Icons.timer,
                                  "وقت الجهوزية: ${line['timeOfPreparation'] ?? 'غير متوفر'} ${line['unitTimeOfPreparation']}",
                                  color: Colors.red),
                              buildRowWithIcon(Icons.location_city,
                                  "المدينة: ${line['city'] ?? 'غير متوفر'}",
                                  color: Colors.purple),
                              buildRowWithIcon(Icons.map,
                                  "الموقع: ${line['location'] ?? 'غير متوفر'}",
                                  color: Colors.green),
                              buildRowWithIcon(Icons.agriculture,
                                  "اسم المحصول: ${line['materialType'] ?? 'غير متوفر'}",
                                  color: Colors.orange),
                              buildRowWithIcon(Icons.calendar_today,
                                  "أيام العمل: ${line['datesOfWork'] ?? 'غير متوفر'}",
                                  color: Colors.teal),
                              buildRowWithIcon(Icons.access_time,
                                  "وقت الدوام: ${line['startWorkTime'] ?? 'غير متوفر'} - ${line['endWorkTime'] ?? 'غير متوفر'}",
                                  color: Colors.pink),
                              buildRowWithIcon(Icons.person,
                                  "صاحب خط الإنتاج: ${line['ownerUsername'] ?? 'غير متوفر'}",
                                  color: Colors.cyan),
                              buildRowWithIcon(Icons.attach_money,
                                  "السعر: ₪ ${line['price'] ?? 'غير متوفر'} / ${line['quantityUnit']}",
                                  color: Colors.deepOrange),
                              buildRowWithIcon(Icons.date_range,
                                  "تاريخ النشر: ${line['publishingDate'].toString().substring(0, 10) ?? 'غير متوفر'}",
                                  color: Colors.brown),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for row with icon and text
  Widget buildRowWithIcon(IconData icon, String text, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
