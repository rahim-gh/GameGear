import 'package:flutter/material.dart';

import '../../shared/constant/app_theme.dart';

class ProductScreen extends StatefulWidget {
  final product;
  const ProductScreen({super.key, this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
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
                border: Border.all(color: AppTheme.greyShadeColor, width: 0.5),
                color: AppTheme.primaryColor,
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
                        color: AppTheme.accentColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 40,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.product['colors'].length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor =
                                          widget.product['colors'][index];
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: selectedColor ==
                                                  widget.product['colors']
                                                      [index]
                                              ? AppTheme.accentColor
                                              : AppTheme.greyShadeColor,
                                          width: 2),
                                      shape: BoxShape.circle,
                                      color: widget.product['colors'][index],
                                    ),
                                  ),
                                );
                              }),
                        ),
                        Row(
                          children: [
                            MaterialButton(
                              color: AppTheme.greyShadeColor,
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
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text('$quantity'),
                            MaterialButton(
                              color: AppTheme.accentColor,
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
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.greyShadeColor, width: 0.5),
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          widget.product['description'],
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.accentColor,
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
                              '\$${widget.product['price'] * quantity}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor),
                            ),
                            Text(
                              'Total payable',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.greyShadeColor),
                            ),
                          ],
                        ),
                        MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minWidth: 150,
                            height: 50,
                            color: AppTheme.accentColor,
                            onPressed: () {},
                            child: Row(
                              spacing: 3,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: AppTheme.primaryColor,
                                  size: 25,
                                ),
                                Text(
                                  'Add to basket',
                                  style: TextStyle(
                                      color: AppTheme.primaryColor,
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
