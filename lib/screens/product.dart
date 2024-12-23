import 'package:flutter/material.dart';
import 'package:login_page/widgets/ItemWidget.dart';
import 'package:login_page/widgets/Item2Widget.dart';
import 'package:login_page/widgets/Item3Widget.dart';
import 'package:login_page/widgets/Dealwidget.dart';
import 'package:login_page/screens/custom_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To handle JSON decoding
import 'config.dart';
import 'package:login_page/screens/itemPage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProductsPage extends StatefulWidget {
  final String token;
  final String userId;
  const ProductsPage({required this.token, Key? key, required this.userId}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = []; // List to hold the products محصول
  List<dynamic> products2 = []; // List to hold the products منتج غذائي
  List<dynamic> products3 = []; // List to hold the products منتج غير غذائي
  int typee = 1;
  int round = 1;
  late String username = "";
  String searchQuery = '';
  String searchCategory = 'crop';

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecoderToken = JwtDecoder.decode(widget.token);
    print(jwtDecoderToken);
    username = jwtDecoderToken['username'] ?? 'No username';
    fetchProducts(); // Call the fetch function when the page is loaded
    fetchProducts2();
    fetchProducts3();
  }

  // Fetch products from the backend
  void fetchProducts() async {
    print("sent username: $username");
    final response = await http.get(
      Uri.parse('$getProducts1/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products = data['products']; // Update the products list
        });
      } else {
        print("Error fetching products: ${data['message']}");
      }
    } else {
      print("Failed to load products: ${response.statusCode}");
    }
  }

  ////////lkj[ y`hzd]
  void fetchProducts3() async {
    final response = await http.get(
      Uri.parse('$getProducts2/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products2 = data['products']; // Update the products list
        });
      } else {
        print("Error fetching products: ${data['message']}");
      }
    } else {
      print("Failed to load products: ${response.statusCode}");
    }
  }

  ////////منتج غير غذائي
  void fetchProducts2() async {
    final response = await http.get(
      Uri.parse('$getProducts3/$username'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products3 = data['products']; // Update the products list
        });
      } else {
        print("Error fetching products: ${data['message']}");
      }
    } else {
      print("Failed to load products: ${response.statusCode}");
    }
  }

  void searchProducts1() async {
    final response = await http.get(
      Uri.parse('$getProducts1/$username?search=$searchQuery'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products =
              data['products']; // Update the lands list with the search result
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  void searchProducts2() async {
    final response = await http.get(
      Uri.parse('$getProducts2/$username?search=$searchQuery'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products2 =
              data['products']; // Update the lands list with the search result
        });
      } else {
        print("Error fetching lands: ${data['message']}");
      }
    } else {
      print("Failed to load lands: ${response.statusCode}");
    }
  }

  void searchProducts3() async {
    final response = await http.get(
      Uri.parse('$getProducts3/$username?search=$searchQuery'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          products3 =
              data['products']; // Update the lands list with the search result
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Color(0xFF556B2F),
            ),
            titleTextStyle: const TextStyle(
              color: Color(0xFF556B2F),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'CustomArabicFont',
            ),
            elevation: 0,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '  شراء منتجات زراعية',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'محاصيل'),
                Tab(text: 'منتج غذائي'),
                Tab(text: 'منتج غير غذائي'),
              ],
              indicatorColor: Color(0xFF556B2F),
              labelColor: Color(0xFF556B2F),
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'CustomArabicFont',
              ),
            ),
          ),
          endDrawer: CustomDrawer(token: widget.token),
          body: Column(
            children: [
              const SizedBox(height: 8.0),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab content for "محاصيل"
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Adjust the width as needed
                                child: TextField(
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  onChanged: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query
                                    });
                                  },
                                  onSubmitted: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query with the entered text
                                    });

                                    searchProducts1();

                                    // Trigger the search function
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'البحث باستخدام اسم المنتج',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF556B2F),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.filter_list,
                                        color: Color(0xFF556B2F),
                                      ),
                                      onPressed: () {
                                        // Add your filter functionality here
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(
                                        0xFFF5F5DC), // Beige background
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ), // Adjust padding inside the TextField
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF556B2F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(top: 15, left: 10),
                            child: const Text(
                              "أهـم التفاصيـل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                SizedBox(height: 10),
                                DealWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerRight,
                            margin:
                                const EdgeInsets.only(right: 10, bottom: 10),
                            child: const Text(
                              "أجدد المحاصيل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              var product = products[index];

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the ItemPage and pass the product details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ItemPage(
                                          userId: widget.userId,
                                            type: 1,
                                            productName: product['name'],
                                            productDescription:
                                                product['description'],
                                            productPrice: product['price'],
                                            profilePhotoBase64: product[
                                                'image'], // Assuming image is base64
                                            quantityType:
                                                product['quantityType'],
                                            quantityAvailable:
                                                product['quantity'],
                                            token: widget.token,
                                            productId: product['_id'],
                                            productRate:
                                                (product['rate'] as num)
                                                    .toDouble(),
                                            username: product['username'],
                                            preparationTime:
                                                product['preparationTime'],
                                            preparationUnit:
                                                product['preparationTimeUnit'],
                                            ownerUsername:
                                                product['username'])),
                                  );
                                },
                                child: ItemWidget(
                                  productName: product['name'],
                                  productDescription: product['description'],
                                  productPrice: product['price'],
                                  profilePhotoBase64: product['image'],
                                  quantityType: product['quantityType'],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    // Tab content for "منتج غذائي"
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Adjust the width as needed
                                child: TextField(
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  onChanged: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query
                                    });
                                  },
                                  onSubmitted: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query with the entered text
                                    });

                                    searchProducts2();

                                    // Trigger the search function
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'البحث باستخدام اسم المنتج',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF556B2F),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.filter_list,
                                        color: Color(0xFF556B2F),
                                      ),
                                      onPressed: () {
                                        // Add your filter functionality here
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(
                                        0xFFF5F5DC), // Beige background
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ), // Adjust padding inside the TextField
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF556B2F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(top: 15, left: 10),
                            child: const Text(
                              "أهـم التفاصيـل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                SizedBox(height: 10),
                                DealWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerRight,
                            margin:
                                const EdgeInsets.only(right: 10, bottom: 10),
                            child: const Text(
                              "أجدد المحاصيل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                            ),
                            itemCount: products2.length,
                            itemBuilder: (context, index) {
                              var product2 = products2[index];

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the ItemPage and pass the product details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemPage(
                                        userId: widget.userId,
                                          type: 2,
                                          productName: product2['name'],
                                          productDescription:
                                              product2['description'],
                                          productPrice: product2['price'],
                                          profilePhotoBase64: product2[
                                              'image'], // Assuming image is base64
                                          quantityType:
                                              product2['quantityType'],
                                          quantityAvailable:
                                              product2['quantity'],
                                          token: widget.token,
                                          productId: product2['_id'],
                                          productRate: (product2['rate'] as num)
                                              .toDouble(),
                                          username: product2['username'],
                                          preparationTime:
                                              product2['preparationTime'],
                                          preparationUnit:
                                              product2['preparationTimeUnit'],
                                          ownerUsername: product2['username']),
                                    ),
                                  );
                                },
                                child: Item2Widget(
                                  productName: product2['name'],
                                  productDescription: product2['description'],
                                  productPrice: product2['price'],
                                  profilePhotoBase64: product2['image'],
                                  quantityType: product2['quantityType'],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    // Tab content for "منتج غير غذائي"

                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Adjust the width as needed
                                child: TextField(
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  onChanged: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query
                                    });
                                  },
                                  onSubmitted: (text) {
                                    setState(() {
                                      searchQuery =
                                          text; // Update the search query with the entered text
                                    });

                                    searchProducts3();

                                    // Trigger the search function
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'البحث باستخدام اسم المنتج',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF556B2F),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.filter_list,
                                        color: Color(0xFF556B2F),
                                      ),
                                      onPressed: () {
                                        // Add your filter functionality here
                                      },
                                    ),
                                    filled: true,
                                    fillColor: const Color(
                                        0xFFF5F5DC), // Beige background
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ), // Adjust padding inside the TextField
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF556B2F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(top: 15, left: 10),
                            child: const Text(
                              "أهـم التفاصيـل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                SizedBox(height: 10),
                                DealWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerRight,
                            margin:
                                const EdgeInsets.only(right: 10, bottom: 10),
                            child: const Text(
                              "أجدد المحاصيل",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF556B2F),
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFD1E7D6),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 5),
                                  ),
                                  Shadow(
                                    color: Color(0xFFF5F5DC),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                            ),
                            itemCount: products3.length,
                            itemBuilder: (context, index) {
                              var product3 = products3[index];

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the ItemPage and pass the product details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemPage(
                                        userId: widget.userId,
                                          type: 3,

                                          productName: product3['name'],
                                          productDescription:
                                              product3['description'],
                                          productPrice: product3['price'],
                                          profilePhotoBase64: product3[
                                              'image'], // Assuming image is base64
                                          quantityType:
                                              product3['quantityType'],
                                          quantityAvailable:
                                              product3['quantity'],
                                          token: widget.token,
                                          productId: product3['_id'],
                                          productRate: (product3['rate'] as num)
                                              .toDouble(),
                                          username: product3['username'],
                                          preparationTime:
                                              product3['preparationTime'],
                                          preparationUnit:
                                              product3['preparationTimeUnit'],
                                          ownerUsername: product3['username']),
                                    ),
                                  );
                                },
                                child: Item3Widget(
                                  productName: product3['name'],
                                  productDescription: product3['description'],
                                  productPrice: product3['price'],
                                  profilePhotoBase64: product3['image'],
                                  quantityType: product3['quantityType'],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
