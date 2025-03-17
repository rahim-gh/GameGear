import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../screen/product_screen/product_screen.dart';
import '../constant/app_asset.dart';
import '../constant/app_color.dart';

class ProductWidget extends StatelessWidget {
  final int index;
  const ProductWidget({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductScreen(product: AppAsset.products[index]);
        }));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
          color: AppColor.primary,
        ),
        margin: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppAsset.products[index]['name'],
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: AppColor.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: AppAsset.products[index]['imageUrl'],
                    child: ClipRRect(
                        child: Image(
                            width: 120,
                            fit: BoxFit.fill,
                            image: AssetImage(
                                AppAsset.products[index]['imageUrl']))),
                  ),
                  Column(
                    children: [
                      Text(
                        "${AppAsset.products[index]['price']}\$",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(AppColor.accent),
                          foregroundColor:
                              WidgetStateProperty.all(AppColor.primary),
                        ),
                        onPressed: () {
                          if (kDebugMode) {
                            print(
                                "${AppAsset.products[index]["name"]} is added to basket");
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
