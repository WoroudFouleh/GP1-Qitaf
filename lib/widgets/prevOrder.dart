import 'package:flutter/material.dart';
import 'package:login_page/screens/orderDetails.dart';

class Prevorder extends StatelessWidget {
  final String orderId;
  final int price;
  final String status;
  final String orderDate;
  final String imagePath;
  final List<dynamic> items;
  final int num;
  final String username;
  const Prevorder({
    Key? key,
    required this.orderId,
    required this.price,
    required this.status,
    required this.orderDate,
    required this.items,
    required this.num,
    this.imagePath = 'assets/images/vegBag.png',
    required this.username, // Default image
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the final status
    String finalStatus = status;
    if (status == 'غير مستلم') {
      // Check if all items have itemStatus == 'delivered'
      bool allDelivered =
          items.every((item) => item['itemStatus'] == 'delivered');
      finalStatus = allDelivered ? 'مستلم' : 'غير مستلم';
    }

    final String formattedDate = orderDate.split(" ")[0];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 5), // Changes position of shadow
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        elevation: 0, // Use 0 here since we are applying a custom shadow
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        finalStatus,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "رقم الطلب: $num",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "السعر: ₪${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    imagePath,
                    width: 80,
                    height: 80,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                thickness: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Orderdetails(
                              price: price,
                              status: finalStatus,
                              date: orderDate,
                              items: items,
                              username: username),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromRGBO(15, 99, 43, 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "  تفاصيل  ",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "تاريخ الطلب: ${orderDate.toString().substring(0, 10)}   ",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
