import 'package:flutter/material.dart';
import '../../core/style/colors.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;   // أي Widget اختياري على الشمال
  final Widget? trailing;  // أي Widget اختياري على اليمين (مثل زر Skip)

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColor.primary_color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(120),
          bottomRight: Radius.circular(120),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (leading != null)
            Positioned(
              left: 8,
              top: 0,
              child: leading!,
            ),
          if (trailing != null)
            Positioned(
              right: 8,
              top: 0,
              child: trailing!,
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
