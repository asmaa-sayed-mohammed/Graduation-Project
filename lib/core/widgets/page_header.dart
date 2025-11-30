import 'package:flutter/material.dart';
import '../../core/style/colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.primary_color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(120),
          bottomRight: Radius.circular(120),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              color: AppColor.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColor.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
