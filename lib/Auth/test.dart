import 'package:flutter/material.dart';

//import '../model/food.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
  }) : super(key: key);
  //final Food food;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          header(),
          const SizedBox(height: 20),
          image(),
          details(),
        ],
      ),
    );
  }

  Container details() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "widget.food.name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 34,
                      ),
                    ),
                    Text('80',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        )),
                  ],
                ),
              ),
              Material(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          quantity -= 1;
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$quantity',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        quantity += 1;
                        setState(() {});
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                "5",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.fiber_manual_record, color: Colors.red),
              SizedBox(width: 4),
              Text(
                '6 kcal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.access_time_filled, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                "40 min",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'About Food',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            " widget.food.description",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          Material(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: const Text(
                  'Add to Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  SizedBox image() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.green[300]!,
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: Image.asset(
                  'assets/images/food.jpg',
                  fit: BoxFit.cover,
                  width: 250,
                  height: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: const BackButton(color: Colors.white),
          ),
          const Spacer(),
          Text(
            'Details Food',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          const Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
