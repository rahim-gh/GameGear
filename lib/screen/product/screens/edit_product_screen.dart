import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../../shared/constant/app_theme.dart';
import '../../../shared/model/product_model.dart';
import '../../../shared/service/database_service.dart';
import '../../../shared/utils/logger_util.dart';
import '../../../shared/widget/appbar_widget.dart';
import '../../../shared/widget/button_widget.dart';
import '../../../shared/widget/input_widget.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  List<File> _newImageFiles = [];
  List<String> _existingImagesBase64 = [];
  int _quantity = 1;
  bool _isLoading = false;
  late Future<Product?> _productFuture;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _productFuture = DatabaseService().getProduct(widget.productId);
    _productFuture.then((product) {
      if (product != null) {
        _product = product;
        _initializeForm();
      }
    });
  }

  void _initializeForm() {
    _nameController.text = _product!.name;
    _priceController.text = _product!.price.toString();
    _descriptionController.text = _product!.description;
    _tagsController.text = _product!.tags.join(', ');
    _quantity = _product!.quantity;
    _existingImagesBase64 = _product!.imagesBase64 ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _getTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImageFiles = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      logs('Error picking images: $e', level: Level.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: ${e.toString()}')),
      );
    }
  }

  Future<List<String>> _getAllImagesBase64() async {
    final List<String> allImages = [..._existingImagesBase64];

    if (_newImageFiles.isNotEmpty) {
      for (final file in _newImageFiles) {
        final bytes = await file.readAsBytes();
        allImages.add(base64Encode(bytes));
      }
    }

    return allImages;
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _updateProduct() async {
    if (_product == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Product(
        id: _product!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        tags: _getTags(),
        imagesBase64: await _getAllImagesBase64(),
        ownerUid: _product!.ownerUid,
        createdAt: _product!.createdAt,
        rate: _product!.rate,
        quantity: _quantity,
      );

// In _updateProduct method:
      await DatabaseService().updateProduct(_product!.id, updatedProduct);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.of(context).pop(true); // This is the key change
    } on DatabaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    final imagesToShow = [
      ..._existingImagesBase64,
      ..._newImageFiles.map((_) => null)
    ];

    if (imagesToShow.isEmpty) {
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
            itemCount: imagesToShow.length,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBarWidget(title: 'Edit Product'),
        body: FutureBuilder<Product?>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Product not found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    InputFieldWidget(
                      controller: _nameController,
                      label: 'Name',
                      type: 'normal',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    InputFieldWidget(
                      controller: _priceController,
                      label: 'Price',
                      type: 'price',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                              border:
                                  Border.all(color: AppTheme.greyShadeColor),
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
                      type: 'normal',
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
                              Text('$_quantity',
                                  style: const TextStyle(fontSize: 18)),
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
                      label: 'Save Changes',
                      onPressed: _updateProduct,
                    ),
                  ],
                ),
              );
            }));
  }
}
