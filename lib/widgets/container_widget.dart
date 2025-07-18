import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ContainerWidget({
    super.key,
    required this.children,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Divider(color: Colors.white54),
          ...children,
        ],
      ),
    );
  }
}
