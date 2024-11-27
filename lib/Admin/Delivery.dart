import 'package:flutter/material.dart';

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Two tabs: Add Delivery and Manage Delivery
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
        automaticallyImplyLeading: false, // Removes the back button
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0), // No extra space below tabs
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'إضافة توصيل'),
              Tab(text: 'إدارة التوصيلات'),
            ],
            indicatorColor: const Color.fromARGB(
                255, 17, 118, 21), // Change indicator color to zayti
            labelColor: const Color.fromARGB(
                255, 17, 118, 21), // Change label color to zayti
            unselectedLabelColor:
                Colors.black, // Change unselected label color to black
          ),
        ),
        elevation: 0, // Removes shadow from app bar
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddDeliveryScreen(),
          ManageDeliveryScreen(),
        ],
      ),
    );
  }
}

class AddDeliveryScreen extends StatefulWidget {
  @override
  _AddDeliveryScreenState createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isConfirmPasswordObscured = true; // For confirming password

  // For city selection
  String? _selectedCity;

  final List<String> cities = [
    'رام الله',
    'نابلس',
    'الخليل',
    'جنين',
    'بيت لحم',
    'طولكرم',
    'غزة',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 25.0),
              // First Name
              TextFormField(
                textAlign: TextAlign.right, // Right alignment for Arabic
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('الاسم الأول'),
                  ),
                  hintText: 'أدخل اسمك الأول',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسمك الأول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              // Last Name
              TextFormField(
                textAlign: TextAlign.right, // Right alignment for Arabic
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('اسم العائلة'),
                  ),
                  hintText: 'أدخل اسم العائلة',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم العائلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              // Phone Number with Country Code
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: '+970',
                      items: ['+970', '+972'].map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(code),
                        );
                      }).toList(),
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        label: const Text('المقدمة'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.right, // Right alignment for Arabic
                      decoration: InputDecoration(
                        label: const Align(
                          alignment: Alignment.centerRight,
                          child: Text('رقم الهاتف'),
                        ),
                        hintText: 'أدخل رقم هاتفك',
                        hintStyle: const TextStyle(color: Colors.black26),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              // Email
              TextFormField(
                textAlign: TextAlign.right, // Right alignment for Arabic
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('البريد الإلكتروني'),
                  ),
                  hintText: 'أدخل بريدك الإلكتروني',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              // Password
              TextFormField(
                obscureText: _isObscured,
                textAlign: TextAlign.right, // Right alignment for Arabic
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('كلمة السر'),
                  ),
                  hintText: 'أدخل كلمة السر',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة السر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              // Confirm Password
              TextFormField(
                obscureText: _isConfirmPasswordObscured,
                textAlign: TextAlign.right, // Right alignment for Arabic
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('تأكيد كلمة السر'),
                  ),
                  hintText: 'أعد إدخال كلمة السر',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordObscured =
                            !_isConfirmPasswordObscured;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى تأكيد كلمة السر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              // City Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCity,
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                decoration: InputDecoration(
                  label: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('اختار المدينة'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار المدينة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 118, 21),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('إضافة توصيل'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageDeliveryScreen extends StatefulWidget {
  @override
  _ManageDeliveryScreenState createState() => _ManageDeliveryScreenState();
}

class _ManageDeliveryScreenState extends State<ManageDeliveryScreen> {
  // Update the type of the map to support nullable strings for 'image'

  List<Map<String, String?>> allDeliveries = [
    {
      'name': 'سامي بدر',
      'phone': '972598126148+',
      'city': 'رام الله',
      'image': null,
    },
    {
      'name': 'رامي خالد',
      'phone': '970599778821+',
      'city': 'نابلس',
      'image': 'assets/images/profilew.png'
    },
    {
      'name': 'علي حسن',
      'phone': '970599123456+',
      'city': 'جنين',
      'image': null,
    },
    {
      'name': 'محمد عادل',
      'phone': '970592334455+',
      'city': 'رام الله',
      'image': 'assets/images/profilew.png'
    },
  ];

  List<Map<String, String?>> filteredDeliveries = [];
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    filteredDeliveries = allDeliveries; // عرض جميع التوصيلات بشكل افتراضي
  }

  void filterByCity(String city) {
    setState(() {
      filteredDeliveries =
          allDeliveries.where((delivery) => delivery['city'] == city).toList();
    });
  }

  void resetFilter() {
    setState(() {
      filteredDeliveries = allDeliveries;
      selectedCity = null;
    });
  }

  void _showDeleteDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'حذف',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.warning, color: Colors.red),
            ],
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا الموصل؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel, color: Colors.grey),
              label: const Text(
                'لا',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  filteredDeliveries
                      .removeWhere((item) => item['name'] == name);
                  allDeliveries.removeWhere((item) => item['name'] == name);
                });
                Navigator.of(context).pop();
                _showSuccessDialog();
              },
              icon: const Icon(Icons.check, color: Colors.green),
              label: const Text(
                'نعم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'تم حذف الموصل بنجاح!',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              Icon(Icons.check_circle, color: Colors.green, size: 40),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.done, color: Colors.green),
              label: const Text(
                'تم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            alignment: AlignmentDirectional.centerEnd,
            value: selectedCity,
            hint: const Text(
              'اختر المدينة',
              textAlign: TextAlign.right,
            ),
            items: allDeliveries
                .map((delivery) => delivery['city'])
                .toSet()
                .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city!, textAlign: TextAlign.right),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                filterByCity(value);
                setState(() {
                  selectedCity = value;
                });
              }
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (selectedCity != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: resetFilter,
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  'إعادة التصفية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDeliveries.length,
              itemBuilder: (context, index) {
                final deliveryMan = filteredDeliveries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      backgroundImage: deliveryMan['image'] != null
                          ? AssetImage(
                              deliveryMan['image']!) // استخدام AssetImage هنا
                          : null,
                      child: deliveryMan['image'] == null
                          ? Text(
                              deliveryMan['name']![0],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      deliveryMan['name']!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'رقم الهاتف: ${deliveryMan['phone']}',
                      textAlign: TextAlign.right,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(deliveryMan['name']!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
