import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Downscales and re-encodes a photo before it is sent to a vision or OCR
/// model: phone photos are 3 to 5 MB, which is slow on mobile data and
/// above what an inline data URL should carry. Runs off the UI isolate.
class ImagePrep {
  ImagePrep._();

  /// Long edge after resizing. Enough for printed text and handwriting.
  static const int maxEdge = 1280;
  static const int jpegQuality = 80;

  /// Returns a `data:image/jpeg;base64,...` URL, or null when [bytes] is not
  /// a decodable image.
  static Future<String?> toJpegDataUrl(Uint8List bytes) async {
    final jpeg = await compute(_resizeToJpeg, bytes);
    if (jpeg == null) return null;
    return 'data:image/jpeg;base64,${base64Encode(jpeg)}';
  }

  @visibleForTesting
  static Uint8List? resizeToJpegSync(Uint8List bytes) => _resizeToJpeg(bytes);

  static Uint8List? _resizeToJpeg(Uint8List bytes) {
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      // Some decoders throw (RangeError) on truncated or non-image bytes
      // instead of returning null.
      return null;
    }
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    final longEdge = oriented.width > oriented.height ? oriented.width : oriented.height;
    final resized = longEdge <= maxEdge
        ? oriented
        : oriented.width >= oriented.height
            ? img.copyResize(oriented, width: maxEdge, interpolation: img.Interpolation.average)
            : img.copyResize(oriented, height: maxEdge, interpolation: img.Interpolation.average);
    return Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
  }
}
