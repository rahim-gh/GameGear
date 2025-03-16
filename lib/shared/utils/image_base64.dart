import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ImageBase64 {
  /// Converts an image file to a base64 string.
  /// If [imagePath] is null, fetches a fallback PNG image from ui-avatars,
  /// converts it to base64, and returns the encoded string.
  Future<String> toBase64(String? imagePath, {String? name}) async {
    logs('Converting image to base64...', level: Level.debug);
    try {
      if (imagePath == null) {
        // Append &format=png to ensure a PNG image is returned.
        final fallbackUrl =
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name ?? "Unknown")}&format=png';
        logs(
          'No image provided. Fetching fallback image from $fallbackUrl',
          level: Level.warning,
        );

        // Fetch the fallback image from the network.
        final response = await http.get(Uri.parse(fallbackUrl));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return base64Encode(response.bodyBytes);
        } else {
          logs(
            'Error fetching fallback image. Status code: ${response.statusCode}',
            level: Level.error,
          );
          throw Exception('Failed to fetch fallback image');
        }
      }

      // Convert the local file to base64.
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      logs('Error converting image to base64: $e',
          level: Level.error, error: e);
      rethrow;
    }
  }

  /// Returns an Image widget from a base64 string.
  /// If [base64String] is null or empty, falls back to a network image from ui-avatars.
  Image toImage(String? base64String,
      {String? name, BoxFit fit = BoxFit.cover}) {
    logs('Converting from base64 to raw image...', level: Level.debug);
    try {
      if (base64String == null || base64String.isEmpty) {
        // Use the fallback with explicit PNG format.
        final fallbackUrl =
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name ?? "Unknown")}&format=png';
        logs(
          'No base64 string provided, fallback to avatar service at $fallbackUrl',
          level: Level.warning,
        );
        return Image.network(
          fallbackUrl,
          fit: fit,
        );
      }

      logs('Image found, converting to raw Image...', level: Level.info);
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: fit,
      );
    } catch (e) {
      logs('Error converting image.', level: Level.error, error: e);
      rethrow;
    }
  }
}
