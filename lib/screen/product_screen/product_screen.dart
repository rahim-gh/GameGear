import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_color.dart';

class ProductScreen extends StatefulWidget {
  final product;
  const ProductScreen({super.key, this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBar(
        title: Text(
          '${widget.product['name']}',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.product['imageUrl'],
              child: Image(
                image: AssetImage(widget.product['imageUrl']),
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.greyShade, width: 0.5),
                color: AppColor.primary,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  spacing: 5,
                  children: [
                    Text(
                      widget.product['name'],
                      style: TextStyle(
                        color: AppColor.accent,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "⭐" * widget.product['rating'],
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          children: [
                            MaterialButton(
                              color: AppColor.greyShade,
                              shape: CircleBorder(),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              },
                              child: Icon(
                                Icons.remove,
                                color: AppColor.primary,
                              ),
                            ),
                            Text('$quantity'),
                            MaterialButton(
                              color: AppColor.accent,
                              shape: CircleBorder(),
                              onPressed: () {
                                setState(() {
                                  if (quantity < widget.product['stock']) {
                                    quantity++;
                                  }
                                });
                              },
                              child: Icon(
                                Icons.add,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColor.greyShade, width: 0.5),
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          widget.product['description'],
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColor.accent,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${widget.product['price']}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.accent),
                            ),
                            Text(
                              'Total payable',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.greyShade),
                            ),
                          ],
                        ),
                        MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minWidth: 150,
                            height: 50,
                            color: AppColor.accent,
                            onPressed: () {},
                            child: Row(
                              spacing: 3,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: AppColor.primary,
                                  size: 25,
                                ),
                                Text(
                                  'Add to basket',
                                  style: TextStyle(
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ))
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
