import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ImageBase64 {
  Future<String> convertImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }
}
