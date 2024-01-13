import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_onboarding/ui/scannedinfo.dart';
import 'package:flutter_onboarding/ui/screens/signin_page.dart';
import 'package:flutter_onboarding/util/globaldata.dart';
import 'package:http/http.dart' as http;

import '../models/ProductData.dart';
import '../util/ip_address.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isLoading = false; // State variable for loading indicator

  // Function to initiate barcode scanning
  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      if (!mounted) return;

      if (barcodeScanRes != '-1') {
        setState(() => isLoading = true); // Show loading indicator
        await sendBarcodeToBackend(barcodeScanRes, context);
        setState(() => isLoading = false); // Hide loading indicator
      }
    } catch (e) {
      print("Barcode scanning error: $e");
      setState(
          () => isLoading = false); // Hide loading indicator in case of error
    }
  }

  // Function to send barcode to backend

  Future<void> sendBarcodeToBackend(
      String barcode, BuildContext context) async {
    GlobalData globalData = GlobalData();
    String email = globalData.email;
    var response = await http.post(
      Uri.parse("http://${Globals.ipAddress}:8000/product/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'barcode': barcode, 'email': email}),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      ProductData productData =
          ProductData.fromJson(responseData["all_results"]);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailPage(
                  productData: productData,
                )),
      );
    } else {
      // Handle failure
      print(
          "Failed to send barcode. Status code: ${response.statusCode}. Response body: ${response.body}");
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
              onTap: scanBarcode,
              child: Container(
                width: size.width * .8,
                height: size.height * .8,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator() // Display loading indicator
                      : Column(
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

// Replace NewPage with the actual page you want to navigate to.