import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Function to initiate barcode scanning
  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", // Line color
          "Cancel", // Cancel button text
          true, // Show flash icon
          ScanMode.BARCODE // Scanning mode
          );
      if (!mounted) return;

      // Check if the scan was canceled
      if (barcodeScanRes == '-1') {
        print("Scanning canceled");
      } else {
        print("Scanned Barcode: $barcodeScanRes");
      }
    } catch (e) {
      print("Barcode scanning error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ... other widgets ...
          Positioned(
            top: 100,
            right: 20,
            left: 20,
            child: GestureDetector(
              // Add GestureDetector here
              onTap: scanBarcode, // Call scanBarcode on tap
              child: Container(
                width: size.width * .8,
                height: size.height * .8,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/code-scan.png',
                        height: 100,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Tap to Scan',
                        style: TextStyle(
                          color: Constants.primaryColor.withOpacity(.80),
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ... other widgets ...
        ],
      ),
    );
  }
}
