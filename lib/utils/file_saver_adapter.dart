// lib/utils/file_saver_adapter.dart
//
// Drop-in replacement for the 'file_saver' API on mobile.
// It provides FileSaver.instance.saveFile(...) and MimeType.pdf,
// but under the hood uses flutter_file_dialog (Android/iOS native pickers).

import 'dart:typed_data';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

enum MimeType { pdf }

class FileSaver {
  FileSaver._();
  static final FileSaver instance = FileSaver._();

  Future<void> saveFile({
    required String name,
    required Uint8List bytes,
    required String ext,
    required MimeType mimeType,
  }) async {
    final safeBase = name
        .replaceAll(RegExp(r'[^\w\s.-]+'), '')
        .replaceAll(' ', '_')
        .replaceAll('.$ext', '')
        .trim();

    await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        data: bytes,
        fileName: '$safeBase.$ext',
        mimeTypesFilter: mimeType == MimeType.pdf
            ? const ['application/pdf']
            : null,
      ),
    );
  }
}
