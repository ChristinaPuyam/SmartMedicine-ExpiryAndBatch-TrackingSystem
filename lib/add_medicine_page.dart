
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:medicine_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final manufacturerController = TextEditingController();
  final descriptionController = TextEditingController();
  final barcodeController = TextEditingController();

  bool isScanning = false;
  bool isSaving = false;

  // --------------------------------------------------
  // SCAN MEDICINE BARCODE
  // --------------------------------------------------

  Future<void> scanBarcode() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
    });

    final scannerController = MobileScannerController();

    try {
      final result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Scan Medicine Barcode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Place the barcode inside the camera view.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) {
                        if (capture.barcodes.isEmpty) return;

                        final code =
                            capture.barcodes.first.rawValue;

                        if (code != null && code.isNotEmpty) {
                          Navigator.pop(sheetContext, code);
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Keep the barcode clear and well lit.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          barcodeController.text = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Barcode scanned. You can now verify the medicine details.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to scan barcode: $e'),
        ),
      );
    } finally {
      await scannerController.dispose();

      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // RECOGNIZE TEXT FROM MEDICINE PACKAGE PHOTO
  // --------------------------------------------------

  Future<void> scanMedicinePhoto() async {
    final picker = ImagePicker();

    try {
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null || !mounted) return;

      final inputImage = InputImage.fromFilePath(photo.path);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      try {
        final recognizedText =
        await textRecognizer.processImage(inputImage);

        if (!mounted) return;

        final extractedText = recognizedText.text.trim();

        if (extractedText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No text detected. Try taking a clearer photo.',
              ),
            ),
          );
          return;
        }

        final lines = extractedText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        String? detectedManufacturer;

        for (final line in lines) {
          final lowerLine = line.toLowerCase();

          if (lowerLine.contains('manufactured by') ||
              lowerLine.contains('manufactured for') ||
              lowerLine.contains('marketed by')) {
            detectedManufacturer = line;
            break;
          }
        }

        setState(() {
          // This is a suggestion, not a verified medicine name.
          if (lines.isNotEmpty) {
            nameController.text = lines.first;
          }

          // Keep all extracted text for review.
          descriptionController.text = extractedText;

          if (detectedManufacturer != null) {
            manufacturerController.text =
                detectedManufacturer;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Text extracted. Review and correct the details before saving.',
            ),
          ),
        );
      } finally {
        await textRecognizer.close();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo recognition failed: $e'),
        ),
      );
    }
  }

  // --------------------------------------------------
  // SAVE MEDICINE TO DATABASE THROUGH API
  // --------------------------------------------------

  Future<void> saveMedicine() async {
    if (isSaving) return;

    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty ||
        manufacturerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final result = await ApiService.addMedicine(
        medicineName: nameController.text.trim(),
        category: categoryController.text.trim(),
        manufacturer: manufacturerController.text.trim(),
        description: descriptionController.text.trim(),
        barcode: barcodeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Medicine saved successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save medicine: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // RELEASE CONTROLLERS
  // --------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    manufacturerController.dispose();
    descriptionController.dispose();
    barcodeController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // MEDICINE FORM UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barcode scanner section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quick Medicine Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Scan the barcode or take a photo of the medicine package.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: isScanning ? null : scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('SCAN BARCODE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Package photo recognition button
            OutlinedButton.icon(
              onPressed: scanMedicinePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('TAKE MEDICINE PACKAGE PHOTO'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.all(15),
              ),
            ),

            const SizedBox(height: 15),

            // Barcode field
            TextField(
              controller: barcodeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Scanned Barcode',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Medicine name
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Medicine Name *',
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Category
            TextField(
              controller: categoryController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category *',
                hintText: 'e.g. Tablet, Syrup, Antibiotic',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Manufacturer
            TextField(
              controller: manufacturerController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Manufacturer *',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Description and extracted text
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description / Extracted Package Text',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveMedicine,
                icon: isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving ? 'SAVING...' : 'SAVE MEDICINE',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '* Required fields. Package text recognition only '
                  'suggests details. Verify all information before saving. '
                  'Batch number, expiry date and quantity should be '
                  'recorded separately for each batch.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}