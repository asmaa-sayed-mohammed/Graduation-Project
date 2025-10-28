import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final connectivity = Connectivity();

  Stream checkforInternet() {
    return connectivity.onConnectivityChanged;
  }

  Future<bool> connected() async {
    final results = await connectivity.checkConnectivity();
    // connectivity.onConnectivityChanged.listen((results)=>{
    //   //check for existence of internet
    // });
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }
}
