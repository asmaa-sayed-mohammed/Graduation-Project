import 'package:hive/hive.dart';
part 'profile_model_hive.g.dart';
@HiveType(typeId: 1)
class ProfileHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String? address;

  @HiveField(4)
  String? companyName;

  ProfileHive({
    required this.id,
    required this.name,
    required this.createdAt,
    this.address,
    this.companyName,
  });



}
