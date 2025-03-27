import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/constant/app_theme.dart';
import '../../../shared/model/product_model.dart';
import '../../../shared/service/auth_service.dart';
import '../../../shared/service/database_service.dart';
import '../../../shared/utils/logger_util.dart';
import '../../../shared/widget/appbar_widget.dart';
import '../../../shared/widget/button_widget.dart';
import '../../../shared/widget/input_widget.dart'; // Now using FieldType enum

class ProductFormScreen extends StatefulWidget {
  final String? productId; // If null, form is in "Add" mode.
  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // Global key for the form.
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // For managing images: existing (edit mode) and new selections.
  List<File> _newImageFiles = [];
  List<String> _existingImagesBase64 = [];

  // For quantity
  int _quantity = 1;

  // Loading and mode control.
  bool _isLoading = false;
  bool get isEditMode => widget.productId != null;
  late Future<Product?> _productFuture;
  Product? _product;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Load product details only in edit mode.
      _productFuture = DatabaseService().getProduct(widget.productId!);
      _productFuture.then((product) {
        if (product != null) {
          _product = product;
          _initializeForm();
        } else {
          if (!mounted) return;
          SnackbarWidget.show(
            context: context,
            message: 'Product not found',
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _initializeForm() {
    setState(() {
      _nameController.text = _product!.name;
      _priceController.text = _product!.price.toString();
      _descriptionController.text = _product!.description;
      _tagsController.text = _product!.tags.join(', ');
      _quantity = _product!.quantity;
      _existingImagesBase64 = _product!.imagesBase64 ?? [];
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Parses tags from input.
  List<String> _getTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// Allows multi‑image selection using the image_picker package.
  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _newImageFiles = pickedFiles.map((file) => File(file.path)).toList();
        });
        logs('Selected ${_newImageFiles.length} new images.',
            level: Level.info);
      } else {
        logs('No images selected.', level: Level.warning);
      }
    } catch (e, stackTrace) {
      logs('Error picking images: $e',
          level: Level.error, error: e, stackTrace: stackTrace);
    }
  }

  /// Combines existing and new images and converts new images to base64.
  Future<List<String>> _getAllImagesBase64() async {
    final List<String> allImages = [..._existingImagesBase64];
    for (final file in _newImageFiles) {
      final bytes = await file.readAsBytes();
      allImages.add(base64Encode(bytes));
    }
    return allImages;
  }

  /// Increments product quantity.
  void _incrementQuantity() {
    setState(() => _quantity++);
    logs("Increased quantity to $_quantity", level: Level.debug);
  }

  /// Decrements product quantity ensuring minimum is 1.
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
      logs("Decreased quantity to $_quantity", level: Level.debug);
    } else {
      logs("Quantity is at minimum (1)", level: Level.warning);
    }
  }

  /// Validates input and submits product for creation or update.
  Future<void> _submitProduct() async {
    // Validate form fields first.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Check that at least one image is provided.
    if (_existingImagesBase64.isEmpty && _newImageFiles.isEmpty) {
      SnackbarWidget.show(
        context: context,
        message: 'Please select at least one image',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final product = Product(
        id: isEditMode ? _product!.id : Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        tags: _getTags(),
        imagesBase64: await _getAllImagesBase64(),
        ownerUid: AuthService().currentUser!.uid,
        createdAt: isEditMode ? _product!.createdAt : DateTime.now(),
        rate: isEditMode ? _product!.rate : 0.0,
        quantity: _quantity,
      );

      if (isEditMode) {
        await DatabaseService().updateProduct(product.id, product);
        if (!mounted) return;
        SnackbarWidget.show(
          context: context,
          message: 'Product updated successfully',
        );
      } else {
        await DatabaseService().addProduct(product);
        if (!mounted) return;
        SnackbarWidget.show(
          context: context,
          message: '${product.name} added successfully',
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      SnackbarWidget.show(
        context: context,
        message: 'Operation failed: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Builds image previews for both existing and new images.
  Widget _buildImagePreview() {
    final totalImages = _existingImagesBase64.length + _newImageFiles.length;
    if (totalImages == 0) {
      return ElevatedButton(
        style: AppTheme.buttonStyle,
        onPressed: _pickImages,
        child: const Text('Select Images'),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages,
            itemBuilder: (context, index) {
              if (index < _existingImagesBase64.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Stack(
                    children: [
                      Image.memory(
                        base64Decode(_existingImagesBase64[index]),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingImagesBase64.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final fileIndex = index - _existingImagesBase64.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Stack(
                    children: [
                      Image.file(
                        _newImageFiles[fileIndex],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _newImageFiles.removeAt(fileIndex);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        TextButton(
          onPressed: _pickImages,
          child: const Text('Add More Images'),
        ),
      ],
    );
  }

  /// Builds the common form content with inline validation.
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InputFieldWidget(
              controller: _nameController,
              label: 'Product Name',
              type: FieldType.productName,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            InputFieldWidget(
              controller: _priceController,
              label: 'Price',
              type: FieldType.price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Text("Images", style: AppTheme.titleStyle),
                  const SizedBox(height: 10),
                  _buildImagePreview(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Text('Description', style: AppTheme.titleStyle),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.greyShadeColor, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 150,
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Product description...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InputFieldWidget(
              controller: _tagsController,
              label: 'Tags (comma separated)',
              type: FieldType.tags,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  Text('Quantity', style: AppTheme.titleStyle),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                        color: AppTheme.accentColor,
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              label: isEditMode ? 'Save Changes' : 'Add',
              onPressed: _submitProduct,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.primaryColor,
              appBar: AppBarWidget(title: 'Edit Product'),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              backgroundColor: AppTheme.primaryColor,
              appBar: AppBarWidget(title: 'Edit Product'),
              body: const Center(child: Text('Product not found')),
            );
          }
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            appBar: AppBarWidget(title: 'Edit Product'),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildForm(),
          );
        },
      );
    } else {
      return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBarWidget(title: 'Add Product'),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(),
      );
    }
  }
}
