import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // ثلاث تبويبات: أراضي، منتجات، خطوط إنتاج
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                const Color.fromARGB(255, 17, 118, 21), // لون المؤشر زيتي
            labelColor:
                const Color.fromARGB(255, 17, 118, 21), // لون النص المحدد زيتي
            unselectedLabelColor: Colors.black, // لون النص غير المحدد أسود
          ),
        ),
        elevation: 0, // إزالة الظل من شريط التطبيق
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LandsScreen(), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "أراضي"
          ProductsScreen(), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "منتجات"
          ProductionLinesScreen(), // استبدل هذه الشاشة بالشاشة التي تعرض بيانات "خطوط إنتاج"
        ],
      ),
    );
  }
}

class LandsScreen extends StatefulWidget {
  @override
  _LandsScreenState createState() => _LandsScreenState();
}

class _LandsScreenState extends State<LandsScreen> {
  String? selectedCity; // القيمة المختارة للمدينة

  final List<String> cities = [
    "القدس",
    "رام الله",
    "نابلس",
    "الخليل"
  ]; // قائمة المدن

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
                  // قائمة تصفية حسب المدن
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
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDECF2),
                    ),
                    child: Column(
                      children: [
                        for (int i = 1; i < 2; i++)
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 113, 134, 25)
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
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/a1.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "اسم الأرض الزراعية", // اسم الأرض
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color(0xFF556B2F), // لون زيتي
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.account_circle,
                                                color: Colors.blue, // لون أزرق
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "اسم صاحب الأرض",
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
                                                Icons.location_on,
                                                color: Colors.red, // لون أحمر
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "المدينة، الموقع",
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
                                                Icons.square_foot,
                                                color: Colors.green, // لون أخضر
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "المساحة: 10 دونم",
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
                                                Icons.people,
                                                color:
                                                    Colors.purple, // لون بنفسجي
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "عدد العمال: 5",
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
                                                color: Colors
                                                    .orange, // لون برتقالي
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "السعر: ₪ 50 / لكل ساعة",
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
                                                color:
                                                    Colors.teal, // لون تركوازي
                                                size: 20,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "10-11-2024  - 15-11-2024",
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
                                                "ساعات العمل: 8:00 ص - 5:00 م",
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
                                                "ثمار تمر",
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
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategory;

  final List<String> categories = [
    "محاصيل طازجة",
    "منتجات غذائية",
    "منتجات غير غذائية"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // قائمة التصفية حسب الصنف
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
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDECF2),
                    ),
                    child: Column(
                      children: [
                        // عرض المنتجات
                        for (int i = 1; i < 3; i++) // عدد المنتجات
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 113, 134, 25)
                                          .withOpacity(0.6),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // الصورة الدائرية
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF556B2F),
                                          width: 2,
                                        ),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/a1.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "اسم المنتج",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF556B2F),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          buildRowWithIcon(
                                              Icons.star, "التقييم: 4.5",
                                              color: Colors.amber),
                                          buildRowWithIcon(
                                              Icons.inventory, "الكمية: 20 كغم",
                                              color: Colors.blue),
                                          buildRowWithIcon(Icons.attach_money,
                                              "السعر: ₪ 10 / لكل كيلو",
                                              color: Colors.green),
                                          buildRowWithIcon(Icons.description,
                                              "وصف المنتج: منتج عالي الجودة وطازج.",
                                              color: Colors.purple),
                                          buildRowWithIcon(Icons.timer,
                                              "مدة جهوز الطلب: 3 أيام",
                                              color: Colors.red),
                                          buildRowWithIcon(Icons.person,
                                              "اسم صاحب الأرض: أحمد علي",
                                              color: Colors.teal),
                                          buildRowWithIcon(Icons.date_range,
                                              "تاريخ نشر المنشور: 25-11-2024",
                                              color: Colors.orange),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}

class ProductionLinesScreen extends StatefulWidget {
  @override
  _ProductionLinesScreenState createState() => _ProductionLinesScreenState();
}

class _ProductionLinesScreenState extends State<ProductionLinesScreen> {
  String? selectedCity;

  final List<String> cities = ["نابلس", "رام الله", "جنين", "طولكرم", "الخليل"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // قائمة التصفية حسب المدينة
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
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDECF2),
                    ),
                    child: Column(
                      children: [
                        for (int i = 1; i < 3; i++)
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                              255, 113, 134, 25)
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
                                        image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/a1.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "اسم خط الإنتاج",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF556B2F),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          buildRowWithIcon(
                                              Icons.star, "التقييم: 4.5",
                                              color: Colors.amber),
                                          buildRowWithIcon(Icons.description,
                                              "وصف خط الإنتاج: خط إنتاج متطور.",
                                              color: Colors.blue),
                                          buildRowWithIcon(Icons.timer,
                                              "وقت جهوز الطلب: 5 أيام",
                                              color: Colors.red),
                                          buildRowWithIcon(Icons.location_city,
                                              "المدينة: نابلس",
                                              color: Colors.purple),
                                          buildRowWithIcon(
                                              Icons.map, "الموقع: شارع القدس",
                                              color: Colors.green),
                                          buildRowWithIcon(Icons.agriculture,
                                              "اسم المحصول: زيتون",
                                              color: Colors.orange),
                                          buildRowWithIcon(Icons.calendar_today,
                                              "أيام العمل: السبت - الخميس",
                                              color: Colors.teal),
                                          buildRowWithIcon(Icons.access_time,
                                              "وقت الدوام: 8:00 صباحاً - 5:00 مساءً",
                                              color: Colors.pink),
                                          buildRowWithIcon(Icons.person,
                                              "اسم صاحب خط الإنتاج: محمد خالد",
                                              color: Colors.cyan),
                                          buildRowWithIcon(Icons.attach_money,
                                              "السعر: ₪ 15 / لكل كيلو",
                                              color: Colors.deepOrange),
                                          buildRowWithIcon(Icons.date_range,
                                              "تاريخ نشر المنشور: 25-11-2024",
                                              color: Colors.brown),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
