import 'package:flutter/material.dart';

class FinancialDisclaimer extends StatelessWidget {
  const FinancialDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Disclaimer: This information is for educational purposes only and does not constitute financial advice. Please consult with a qualified financial professional before making any investment decisions.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
