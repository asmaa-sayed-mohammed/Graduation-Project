import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/reading_model_hive.dart';

class ReadingHiveService{
  final Box<ReadingModelHive> readingBox;
  final SupabaseClient supabase = Supabase.instance.client;

  ReadingHiveService(this.readingBox);

  //save the reading
  Future<void> saveReadings(ReadingModelHive readings)async{
    await readingBox.add(readings);

    // if(await _)
  }

  //load all readings
  List<ReadingModelHive> loadReadings(){
    return readingBox.values.toList();
  }

  //load last reading
  ReadingModelHive? loadLastReading(){
    late ReadingModelHive? lastReading;
    ReadingBox.isEmpty ? lastReading = null : lastReading = ReadingBox.getAt(ReadingBox.length - 1);
    return lastReading;
  }

  //check connecting of the internet
  Future<bool>connected()async{
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  //synch with supabase
  Future<void> synchReadings()async{
    final readings = loadReadings();
    for(var reading in readings){
      try{
        await supabase.from('usage_record').insert(reading.toMap());
        return;
      }catch(e){
        print('Sync failed: $e');
        return;
      }
    }

  }


}