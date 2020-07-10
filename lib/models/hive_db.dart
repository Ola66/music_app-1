import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class InitHive {
  void startHive({@required String boxName}) async {
    Directory documentDir = await getApplicationSupportDirectory();
    Hive.init(documentDir.path);
    await Hive.openBox<String>(boxName);
  }
}
