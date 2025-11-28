import 'package:graduation_project/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/history_model.dart';

class SupabaseHistoryService {

  Future<List<UsageRecord>> getHistory(String userId) async {
    final data = await cloud
        .from("usage_record")
        .select()
        .eq("user_id", userId)
        .order("created_at");

    return data.map<UsageRecord>((e) => UsageRecord.fromMap(e)).toList();
  }
}
