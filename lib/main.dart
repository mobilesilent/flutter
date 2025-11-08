import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:automaticmb/home.dart';
import 'package:automaticmb/loginscreen.dart';
import 'package:automaticmb/complaint.dart';
import 'package:automaticmb/feedback.dart';
import 'package:automaticmb/register.dart';
import 'package:automaticmb/timetable.dart';

/// --- CHANGE THIS TO MATCH YOUR PACKAGE NAME ---
const _channelName = 'com.example.automaticmb/dnd'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutomaticMB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home:  Loginscreen(),
    );
  }
}

/// ✅ DND helper class to be used anywhere in the app (e.g., inside HomePage)
class DndHelper {
  static const platform = MethodChannel(_channelName);

  /// Open system settings to grant DND permission
  static Future<String> openDndSettings() async {
    try {
      await platform.invokeMethod('openDndSettings');
      return 'Opened DND settings — grant access.';
    } on PlatformException catch (e) {
      return 'Error opening DND settings: ${e.message}';
    }
  }

  /// Schedule DND mode between two times
  static Future<String> scheduleDnd({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      await platform.invokeMethod('scheduleDnd', {
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
      });
      return 'Scheduled DND from $start → $end';
    } on PlatformException catch (e) {
      return 'Schedule error: ${e.message}';
    }
  }

  /// Cancel DND schedule
  static Future<String> cancelDnd() async {
    try {
      await platform.invokeMethod('cancelDnd');
      return 'Cancelled DND schedule.';
    } on PlatformException catch (e) {
      return 'Cancel error: ${e.message}';
    }
  }
}
