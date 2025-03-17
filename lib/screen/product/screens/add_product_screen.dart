import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/constant/app_data.dart';
import '../../../shared/constant/app_theme.dart';
import '../../../shared/model/product_model.dart';
import '../../../shared/widget/appbar_widget.dart';
import '../../../shared/widget/button_widget.dart';
import '../../../shared/widget/input_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<String> getTags() {
    String tagsText = _tagsController.text;
    List<String> tags = tagsText.split(',').map((tag) => tag.trim()).toList();
    return tags;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final File file = File(imageFile.path);
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      setState(() {
        _imageFile = file;
        _product?.imagesBase64 = [base64Image];
      });
    }
  }

  Product? _product;
  File? _imageFile;
  int quantity = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() {
      _product = Product(
        id: '${AppData.products.length + 1}',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        tags: getTags(),
        imagesBase64: _product?.imagesBase64 ?? [],
        ownerUid: 'ownert123',
        createdAt: DateTime.now(),
        rate: 0.0,
        quantity: quantity,
      );
    });

    if (_product != null) {
      AppData.products.add(_product!);
      Navigator.of(context).pushReplacementNamed('home_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'Add product'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InputFieldWidget(
                controller: _nameController,
                label: 'Name',
                type: 'normal',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              InputFieldWidget(
                controller: _priceController,
                label: 'Price',
                type: 'normal',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Image:", style: AppTheme.titleStyle),
                    SizedBox(height: 10),
                    _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : ElevatedButton(
                            style: AppTheme.buttonStyle,
                            onPressed: _pickImage,
                            child: Text('Select Image'),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Description:', style: AppTheme.titleStyle),
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.greyShadeColor, width: 0.5),
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 150,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Enter product description...',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              InputFieldWidget(
                controller: _tagsController,
                label: 'Tags',
                type: 'normal',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Quantity:', style: AppTheme.titleStyle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: AppTheme.greyShadeColor,
                          shape: const CircleBorder(),
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
                          shape: const CircleBorder(),
                          onPressed: () {
                            setState(() {
                              quantity++;
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
              ),
              SizedBox(height: 20),
              ButtonWidget(
                label: 'Add',
                onPressed: _addProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
