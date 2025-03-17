import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../screen/product_screen/product_screen.dart';
import '../constant/app_theme.dart';
import '../constant/app_data.dart';

class HomeProductWidget extends StatelessWidget {
  final int index;
  const HomeProductWidget({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductScreen(product: AppData.products[index]);
        }));
      },
      child: Container(
        decoration: AppTheme.cardDecoration,
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppData.products[index]['name'],
                style: AppTheme.titleStyle,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: AppData.products[index]['imageUrl'],
                    child: ClipRRect(
                        child: Image(
                            width: 120,
                            fit: BoxFit.fill,
                            image: AssetImage(
                                AppData.products[index]['imageUrl']))),
                  ),
                  Column(
                    children: [
                      Text(
                        "${AppData.products[index]['price']}\$",
                        style: AppTheme.titleStyle,
                      ),
                      ElevatedButton(
                        style: AppTheme.buttonStyle,
                        onPressed: () {
                          if (kDebugMode) {
                            print(
                                "${AppData.products[index]["name"]} is added to basket");
                          }
                        },
                        child: Text("Add to Basket"),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
