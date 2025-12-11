import 'package:hive/hive.dart';

part 'reading_model_hive.g.dart';

@HiveType(typeId: 3)
class ReadingModelHive{

  @HiveField(0)
  final String userId;

  @HiveField(1)
  final double difference_readings;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String chip;

  @HiveField(4)
  final DateTime createdAt;

  ReadingModelHive({required this.userId, required this.difference_readings, required this.price, required this.chip, required this.createdAt, int new_reading = 0, int old_reading = 0, double consumption = 0.0, String date = ''});

  factory ReadingModelHive.fromMap(Map<String, dynamic> map) {
    return ReadingModelHive(
      userId: map['user_id'],
      difference_readings: map['difference_readings'],
      price: map['price'],
      chip: map['chip'],
      createdAt: map['created_at'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'difference_readings': difference_readings,
      'price': price,
      'chip': chip,
      'created_at': createdAt
    };
  }

}