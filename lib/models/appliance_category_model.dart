// models/appliance_category_model.dart
class ApplianceCategory {
  final int id;
  final String nameAr;
  final String? descriptionAr;
  final String? imageUrl;

  ApplianceCategory({
    required this.id,
    required this.nameAr,
    this.descriptionAr,
    this.imageUrl,
  });

  factory ApplianceCategory.fromJson(Map<String, dynamic> json) {
    return ApplianceCategory(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      descriptionAr: json['description_ar'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
    };
  }
}