import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/style/colors.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onSupabaseSave;
  final VoidCallback onHiveSave;
  final String supabaseLabel;
  final String hiveLabel;

  const SaveButton({
    super.key,
    required this.onSupabaseSave,
    required this.onHiveSave,
    this.supabaseLabel = "احسب وحفظ في Supabase",
    this.hiveLabel = "حفظ القراءة في Hive",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زر الحفظ في Supabase
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: onSupabaseSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.primary_color,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                supabaseLabel,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // زر الحفظ في Hive
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: onHiveSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.primary_color,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                hiveLabel,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
