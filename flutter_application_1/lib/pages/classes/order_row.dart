import 'package:flutter/material.dart';

class OrderRow extends StatelessWidget {
  final String imageUrl;
  final String label;
  final TextEditingController controller;
  final String price;

  const OrderRow({
    super.key,
    required this.imageUrl,
    required this.label,
    required this.controller,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
       return Card(
        color: Colors.grey[200],
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Image.asset(imageUrl, width: screenWidth * 0.1), 
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: Text(
                      label,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                  const SizedBox(height: 4,),
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: Text(
                      '₪$price',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: screenWidth * 0.35,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'הכנס כמות',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }
}
