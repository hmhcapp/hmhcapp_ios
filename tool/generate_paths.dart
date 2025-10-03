import 'dart:io';
import 'package:path/path.dart' as p;

// This script scans your assets/pdfs folder and generates the Dart code for your lists.
void main() {
  // Define the base directory to scan.
  final assetsDir = Directory('assets/pdfs');

  if (!assetsDir.existsSync()) {
    print('Error: The directory ${assetsDir.path} does not exist.');
    return;
  }

  print('--- Generating paths for FACTSHEETS ---');
  generateFor(p.join(assetsDir.path, 'FACTSHEETS'));

  print('\n--- Generating paths for INSTRUCTIONS ---');
  generateFor(p.join(assetsDir.path, 'INSTRUCTIONS'));
  
  print('\n--- Generating paths for CASESTUDIES ---');
  generateFor(p.join(assetsDir.path, 'CASESTUDIES'));
}

void generateFor(String directoryPath) {
  final dir = Directory(directoryPath);
  if (!dir.existsSync()) {
    print('// Directory not found: $directoryPath');
    return;
  }

  final files = dir.listSync(recursive: true);

  for (final file in files) {
    if (file is File && file.path.toLowerCase().endsWith('.pdf')) {
      // Get the relative asset path that Flutter needs.
      // IMPORTANT: Replace backslashes with forward slashes for the asset system.
      final assetPath = file.path.replaceAll(r'\', '/');

      // Create a clean name for the UI.
      final fileName = p.basenameWithoutExtension(file.path);
      final displayName = fileName.replaceAll('-', ' ').replaceAll('_', ' ');

      // Print the final Dart code line.
      print('PdfInfo("$displayName", "$assetPath"),');
    }
  }
}