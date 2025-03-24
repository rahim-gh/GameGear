import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/model/product_model.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers for user inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // List to hold selected images for multi‑image support.
  final List<File> _imageFiles = [];

  // For quantity management.
  int quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Extracts and cleans the tags entered by the user.
  List<String> getTags() {
    final tagsText = _tagsController.text;
    final tags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    logs("Parsed tags: $tags", level: Level.debug);
    return tags;
  }

  /// Uses the image_picker to allow multi‑image selection.
  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _imageFiles.clear();
          _imageFiles.addAll(images.map((xfile) => File(xfile.path)));
        });
        logs('Selected ${_imageFiles.length} images.', level: Level.info);
      } else {
        logs('No images selected.', level: Level.warning);
      }
    } catch (e, stackTrace) {
      logs('Error picking images: $e',
          level: Level.error, error: e, stackTrace: stackTrace);
    }
  }

  /// Converts selected image files to a list of base64 strings.
  Future<List<String>> _convertImagesToBase64() async {
    final List<String> base64Images = [];
    try {
      for (final file in _imageFiles) {
        final bytes = await file.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }
      logs('Converted ${base64Images.length} images to base64.',
          level: Level.info);
    } catch (e, stackTrace) {
      logs('Error converting images to base64: $e',
          level: Level.error, error: e, stackTrace: stackTrace);
      rethrow;
    }
    return base64Images;
  }

  /// Safely increments the quantity.
  void _incrementQuantity() {
    try {
      setState(() {
        quantity++;
      });
      logs("Increased quantity to $quantity", level: Level.debug);
    } catch (e, stackTrace) {
      logs("Error increasing quantity: $e",
          level: Level.error, error: e, stackTrace: stackTrace);
    }
  }

  /// Safely decrements the quantity ensuring it doesn't fall below 1.
  void _decrementQuantity() {
    try {
      if (quantity > 1) {
        setState(() {
          quantity--;
        });
        logs("Decreased quantity to $quantity", level: Level.debug);
      } else {
        logs("Quantity is already at minimum (1)", level: Level.warning);
      }
    } catch (e, stackTrace) {
      logs("Error decreasing quantity: $e",
          level: Level.error, error: e, stackTrace: stackTrace);
    }
  }

  /// Validates inputs, constructs a Product, adds it to Firestore, and logs any errors.
  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageFiles.isEmpty) {
      logs("Validation failed: Some fields are empty or no image selected",
          level: Level.warning);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all fields and select at least one image')),
      );
      return;
    }

    try {
      final double price = double.parse(_priceController.text);
      final List<String> tags = getTags();
      final List<String> imagesBase64 = await _convertImagesToBase64();

      final product = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        price: price,
        tags: tags,
        imagesBase64: imagesBase64,
        ownerUid: AuthService().currentUser!.uid,
        createdAt: DateTime.now(),
        rate: 0.0,
        quantity: quantity,
      );

      logs('Product created: ${product.toString()}', level: Level.info);

      // Add product to Firestore via DatabaseService.
      final String productId = await DatabaseService().addProduct(product);
      logs('Product added to Firestore with id: $productId', level: Level.info);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added successfully')),
      );
      logs("Product added successfully", level: Level.info);

      // Optionally navigate back or update UI as needed.
      // Navigator.of(context).pushReplacementNamed('home_screen');
    } catch (e, stackTrace) {
      logs('Error adding product: $e',
          level: Level.error, error: e, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBarWidget(title: 'Add product'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name input field
              InputFieldWidget(
                controller: _nameController,
                label: 'Name',
                type: 'normal',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              // Price input field
              InputFieldWidget(
                controller: _priceController,
                label: 'Price',
                type: 'price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              // Image selection section
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Images:", style: AppTheme.titleStyle),
                    const SizedBox(height: 10),
                    _imageFiles.isNotEmpty
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageFiles.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Image.file(
                                    _imageFiles[index],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          )
                        : ElevatedButton(
                            style: AppTheme.buttonStyle,
                            onPressed: _pickImages,
                            child: const Text('Select Images'),
                          ),
                    if (_imageFiles.isNotEmpty)
                      TextButton(
                        onPressed: _pickImages,
                        child: const Text('Change Images'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Description input section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Description:', style: AppTheme.titleStyle),
                    const SizedBox(height: 10),
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
                          decoration: const InputDecoration(
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
              const SizedBox(height: 20),
              // Tags input field
              InputFieldWidget(
                controller: _tagsController,
                label: 'Tags (comma-separated)',
                type: 'normal',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              // Quantity selection section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Quantity:', style: AppTheme.titleStyle),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: AppTheme.greyShadeColor,
                          shape: const CircleBorder(),
                          onPressed: _decrementQuantity,
                          child: Icon(
                            Icons.remove,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        MaterialButton(
                          color: AppTheme.accentColor,
                          shape: const CircleBorder(),
                          onPressed: _incrementQuantity,
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
              const SizedBox(height: 20),
              // Add button to trigger product creation
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
