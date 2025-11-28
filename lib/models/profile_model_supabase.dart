class ProfileModel {
  final String? id;
  final String name;
  final DateTime? created_at;
  final String? address;
  final String? company_Name;

  ProfileModel({
    this.id,
    required this.name,
    this.created_at,
    this.address,
    this.company_Name,
  });

  // تحويل الـ Model إلى Map عشان نقدر نخزنها في Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': created_at?.toIso8601String(),
      'address': address ?? '',
      'company_Name': company_Name ?? '',
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String?,
      name: map['name'] as String? ?? 'user',
      created_at: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      address: map['address'] as String?,
      company_Name: map['company_Name'] as String?,
    );
  }
}
