import 'package:flutter/material.dart';

import '../../shared/constant/app_theme.dart';
import '../../shared/constant/app_data.dart';
import '../../shared/widget/appbar_widget.dart';
import '../../shared/widget/basket_product_widget.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({
    super.key,
  });
  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Basket"),
      body: Column(spacing: 10, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.primaryColor,
          ),
          width: MediaQuery.of(context).size.width - 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$100',
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: AppTheme.accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: AppTheme.buttonStyle,
                onPressed: () {},
                child: Text('Buy'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: AppData.products.length,
            itemBuilder: (context, index) {
              return BasketProductWidget(index: index);
            },
          ),
        ),
      ]),
    );
  }
}
