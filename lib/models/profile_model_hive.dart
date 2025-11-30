import 'package:hive/hive.dart';

part 'profile_model_hive.g.dart';

@HiveType(typeId: 1)
class ProfileHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String createdAt; // <-- String بدل DateTime

  @HiveField(3)
  String? address;

  @HiveField(4)
  String? companyName; // <-- تعديل الاسم

  ProfileHive({
    required this.id,
    required this.name,
    required this.createdAt,
    this.address,
    this.companyName, String? company_Name,
  });

  // ⬅ تحويل من ProfileModel Supabase إلى Hive
  factory ProfileHive.fromMap(Map<String, dynamic> map) {
    return ProfileHive(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      createdAt: map['created_at'] ?? '',     // <-- String
      address: map['address'],
      companyName: map['company_name'],       // <-- الاسم مظبوط
    );
  }

  // ⬅ لو هترجعي الماب تاني
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "created_at": createdAt,
      "address": address,
      "company_name": companyName,
    };
  }
}
