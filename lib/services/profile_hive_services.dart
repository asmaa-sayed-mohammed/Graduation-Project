import 'package:graduation_project/models/profile_model_hive.dart';
import 'package:hive/hive.dart';

class ProfileHiveService {
  final Box<ProfileHive> profileBox;

  // Constructor
  ProfileHiveService(this.profileBox);

  // Example: Add a profile
  Future<void> addProfile(ProfileHive profile) async {
    await profileBox.put(profile.id,profile);
  }

  ProfileHive? getOneProfile(String id){
    return profileBox.get(id);
  }

  // Example: Get all profiles
  List<ProfileHive> getProfiles() {
    return profileBox.values.toList();
  }

  // Example: Delete a profile
  Future<void> deleteProfile(int key) async {
    await profileBox.delete(key);
  }
}
