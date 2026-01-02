// import 'package:automaticmb/register.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/services.dart';

// const _channelName = 'com.example.automaticmb/dnd';
// const platform = MethodChannel(_channelName);

// class TimetableScreen extends StatefulWidget {
//   const TimetableScreen({super.key});

//   @override
//   State<TimetableScreen> createState() => _TimetableScreenState();
// }

// class _TimetableScreenState extends State<TimetableScreen> {
//   final Dio _dio = Dio();
//   List<Map<String, dynamic>> timings = [];
//   bool isLoading = true;
//   String status = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchTimings();
//   }

//   // ---------------- FETCH ----------------
//   Future<void> fetchTimings() async {
//     setState(() {
//       isLoading = true;
//       status = '';
//     });

//     try {
//       final response = await _dio.get('$baseurl/timings_api/');print(response.data);
//       if (response.statusCode == 200) {
//         timings = List<Map<String, dynamic>>.from(response.data);
//         setState(() => isLoading = false);

//         for (final t in timings) {
//           await _handleTiming(
//             day: t['day'],
//             start: t['start'],
//             end: t['to'],
//             subject: t['subject'] ?? 'Class',
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         status = 'Error fetching timings: $e';
//       });
//     }
//   }

//   // ---------------- DAY HELPERS ----------------
//   int _weekdayFromString(String day) {
//     switch (day.toLowerCase()) {
//       case 'monday':
//         return DateTime.monday;
//       case 'tuesday':
//         return DateTime.tuesday;
//       case 'wednesday':
//         return DateTime.wednesday;
//       case 'thursday':
//         return DateTime.thursday;
//       case 'friday':
//         return DateTime.friday;
//       case 'saturday':
//         return DateTime.saturday;
//       case 'sunday':
//         return DateTime.sunday;
//       default:
//         return DateTime.monday;
//     }
//   }

//   DateTime _nextDateForWeekday(int weekday) {
//     final now = DateTime.now();
//     int diff = weekday - now.weekday;
//     if (diff < 0) diff += 7;
//     return now.add(Duration(days: diff));
//   }

//   // ---------------- CORE LOGIC ----------------
//   Future<void> _handleTiming({
//   required String day,
//   required String start,
//   required String end,
//   required String subject,
// }) async {
//   try {
//     final now = DateTime.now();
//     final weekday = _weekdayFromString(day);
    
//     // Get the next occurrence of this weekday
//     DateTime classDate = _nextDateForWeekday(weekday);
    
//     final sp = start.split(':').map(int.parse).toList();
//     final ep = end.split(':').map(int.parse).toList();
    
//     DateTime startTime = DateTime(
//       classDate.year,
//       classDate.month,
//       classDate.day,
//       sp[0],
//       sp[1],
//       sp.length > 2 ? sp[2] : 0,
//     );
    
//     DateTime endTime = DateTime(
//       classDate.year,
//       classDate.month,
//       classDate.day,
//       ep[0],
//       ep[1],
//       ep.length > 2 ? ep[2] : 0,
//     );
    
//     // Handle overnight classes
//     if (endTime.isBefore(startTime)) {
//       endTime = endTime.add(const Duration(days: 1));
//     }
    
//     // If this class has already COMPLETELY ended (past its end time),
//     // schedule it for the SAME DAY NEXT WEEK
//     if (now.isAfter(endTime)) {
//       startTime = startTime.add(const Duration(days: 7));
//       endTime = endTime.add(const Duration(days: 7));
//     }
    
//     // ACTIVE - class is happening RIGHT NOW
//     if (now.isAfter(startTime) && now.isBefore(endTime)) {
//       await platform.invokeMethod('startDnd');
//       await platform.invokeMethod('scheduleDndEndAt', {
//         'endMillis': endTime.millisecondsSinceEpoch,
//       });
//       setState(() {
//         status += '🔴 ACTIVE $subject ($day) until ${_fmtTime(endTime)}\n';
//       });
//     }
//     // FUTURE - class will happen later (could be today or future)
//     else if (now.isBefore(startTime)) {
//       await platform.invokeMethod('scheduleDndStartAt', {
//         'startMillis': startTime.millisecondsSinceEpoch,
//       });
//       await platform.invokeMethod('scheduleDndEndAt', {
//         'endMillis': endTime.millisecondsSinceEpoch,
//       });
//       setState(() {
//         status +=
//             '⏰ Scheduled $subject ($day) ${_fmtTime(startTime)} → ${_fmtTime(endTime)}\n';
//       });
//     }
//     // If we reach here, the class is exactly at endTime (rare edge case)
//   } catch (e) {
//     setState(() {
//       status += '❌ Error $subject: $e\n';
//     });
//   }
// }
//   String _fmtTime(DateTime dt) =>
//       '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

//   Future<void> _openDndSettings() async {
//     await platform.invokeMethod('openDndSettings');
//   }

//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Timetable DND Scheduler'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: _openDndSettings,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: timings.length,
//                       itemBuilder: (_, i) {
//                         final t = timings[i];
//                         return ListTile(
//                           leading: const Icon(Icons.schedule),
//                           title: Text(t['subject']),
//                           subtitle:
//                               Text('${t['day']} | ${t['start']} - ${t['to']}'),
//                         );
//                       },
//                     ),
//                   ),
//                   if (status.isNotEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       color: Colors.indigo.shade50,
//                       child: SingleChildScrollView(child: Text(status)),
//                     ),
//                 ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchTimings,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:automaticmb/register.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';  
import 'package:permission_handler/permission_handler.dart'; 

const _channelName = 'com.example.automaticmb/dnd';
const platform = MethodChannel(_channelName);

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Dio _dio = Dio();
  List<Map<String, dynamic>> timings = [];
  bool isLoading = true;
  String status = '';
  bool _hasLocationPermission = false;
  Position? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isAtCollege = false;
  List<Map<String, dynamic>> _activeClasses = [];
  
  // Add your college coordinates here
  static const double _collegeLatitude = 11.2578;  
  static const double _collegeLongitude = 75.7887;
  static const double _collegeRadiusMeters = 500.0;  

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    fetchTimings();
  }

  @override
  void dispose() {
    // Stop location updates when screen is disposed
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // ----------------- LOCATION PERMISSION -----------------
  Future<void> _checkLocationPermission() async {
    final permission = await Permission.locationWhenInUse.status;
    if (permission.isGranted) {
      setState(() {
        _hasLocationPermission = true;
      });
      await _startContinuousLocationUpdates();
    } else if (permission.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      if (result.isGranted) {
        setState(() {
          _hasLocationPermission = true;
        });
        await _startContinuousLocationUpdates();
      }
    }
  }

  Future<void> _startContinuousLocationUpdates() async {
    try {
      if (!_hasLocationPermission) return;

      // Start listening to location changes
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 50, // Update every 50 meters movement
          timeLimit: Duration(seconds: 30), // Update every 30 seconds max
        ),
      ).listen((Position position) {
        _handleNewLocation(position);
      });

      // Also get immediate location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      _handleNewLocation(position);
      
    } catch (e) {
      print('Error starting location updates: $e');
    }
  }

  void _handleNewLocation(Position position) {
    setState(() {
      _currentLocation = position;
    });

    // Check if user is at college
    _checkCollegeLocation(position);
    
    // Update DND status based on new location
    _updateDndBasedOnLocation();
  }

  Future<void> _checkCollegeLocation(Position position) async {
    try {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _collegeLatitude,
        _collegeLongitude,
      );

      final newIsAtCollege = distance <= _collegeRadiusMeters;
      
      if (newIsAtCollege != _isAtCollege) {
        setState(() {
          _isAtCollege = newIsAtCollege;
        });
        
        // Log location change
        if (newIsAtCollege) {
          setState(() {
            status += '📍 Entered college area (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})\n';
          });
          // Trigger DND activation for any active classes
          _activateDndForActiveClasses();
        } else {
          setState(() {
            status += '🏠 Left college area (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})\n';
          });
          // Cancel DND if user leaves college
          _cancelDndForActiveClasses();
        }
      }
    } catch (e) {
      print('Error checking college location: $e');
    }
  }

  void _activateDndForActiveClasses() {
    if (_activeClasses.isEmpty) return;
    
    for (final classInfo in _activeClasses) {
      setState(() {
        status += '🎯 Activating DND for ${classInfo['subject']} (arrived at college)\n';
      });
      // Schedule DND for this active class
      _scheduleDndForClass(classInfo);
    }
  }

  void _cancelDndForActiveClasses() {
    if (_activeClasses.isEmpty) return;
    
    setState(() {
      status += '🚫 Cancelling DND for ${_activeClasses.length} active classes (left college)\n';
    });
    
    try {
      // Call Android native to cancel DND
      platform.invokeMethod('cancelDnd');
    } catch (e) {
      print('Error cancelling DND: $e');
    }
  }

  Future<bool> _isUserAtCollege() async {
    // Always use real-time location
    if (!_hasLocationPermission || _currentLocation == null) {
      return false;
    }

    try {
      final distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _collegeLatitude,
        _collegeLongitude,
      );

      return distance <= _collegeRadiusMeters;
    } catch (e) {
      print('Error calculating distance: $e');
      return false;
    }
  }

  void _updateDndBasedOnLocation() {
    // Check all timings again with current location
    if (timings.isNotEmpty) {
      for (final t in timings) {
        _checkAndUpdateClassStatus(
          day: t['day'],
          start: t['start'],
          end: t['to'],
          subject: t['subject'] ?? 'Class',
        );
      }
    }
  }

  // ---------------- FETCH ----------------
  Future<void> fetchTimings() async {
    setState(() {
      isLoading = true;
      status = '';
      _activeClasses.clear();
    });

    try {
      final response = await _dio.get('$baseurl/timings_api/');
      print(response.data);
      if (response.statusCode == 200) {
        timings = List<Map<String, dynamic>>.from(response.data);
        setState(() => isLoading = false);

        for (final t in timings) {
          await _handleTiming(
            day: t['day'],
            start: t['start'],
            end: t['to'],
            subject: t['subject'] ?? 'Class',
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        status = 'Error fetching timings: $e';
      });
    }
  }

  // ---------------- DAY HELPERS ----------------
  int _weekdayFromString(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  DateTime _nextDateForWeekday(int weekday) {
    final now = DateTime.now();
    int diff = weekday - now.weekday;
    if (diff < 0) diff += 7;
    return now.add(Duration(days: diff));
  }

  // ---------------- CORE LOGIC (WITH REALTIME LOCATION) ----------------
  Future<void> _handleTiming({
    required String day,
    required String start,
    required String end,
    required String subject,
  }) async {
    try {
      final now = DateTime.now();
      final weekday = _weekdayFromString(day);
      
      // Get the next occurrence of this weekday
      DateTime classDate = _nextDateForWeekday(weekday);
      
      final sp = start.split(':').map(int.parse).toList();
      final ep = end.split(':').map(int.parse).toList();
      
      DateTime startTime = DateTime(
        classDate.year,
        classDate.month,
        classDate.day,
        sp[0],
        sp[1],
        sp.length > 2 ? sp[2] : 0,
      );
      
      DateTime endTime = DateTime(
        classDate.year,
        classDate.month,
        classDate.day,
        ep[0],
        ep[1],
        ep.length > 2 ? ep[2] : 0,
      );
      
      // Handle overnight classes
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }
      
      // If this class has already COMPLETELY ended (past its end time),
      // schedule it for the SAME DAY NEXT WEEK
      if (now.isAfter(endTime)) {
        startTime = startTime.add(const Duration(days: 7));
        endTime = endTime.add(const Duration(days: 7));
      }
      
      // Check if class is ACTIVE right now
      final bool isClassActive = now.isAfter(startTime) && now.isBefore(endTime);
      
      if (isClassActive) {
        // Add to active classes list
        final classInfo = {
          'day': day,
          'start': start,
          'end': end,
          'subject': subject,
          'startTime': startTime,
          'endTime': endTime,
        };
        
        if (!_activeClasses.any((c) => c['subject'] == subject && c['day'] == day)) {
          _activeClasses.add(classInfo);
        }
        
        // Check current location and activate DND if at college
        if (_isAtCollege) {
          await _scheduleDndForClass(classInfo);
          setState(() {
            status += '🔴 ACTIVE $subject ($day) until ${_fmtTime(endTime)} (At College)\n';
          });
        } else {
          setState(() {
            status += '🏠 ACTIVE $subject ($day) but NOT at college - NO DND\n';
          });
        }
      }
      // FUTURE - class will happen later
      else if (now.isBefore(startTime)) {
        final isAtCollege = await _isUserAtCollege();
        
        if (isAtCollege) {
          await platform.invokeMethod('scheduleDndStartAt', {
            'startMillis': startTime.millisecondsSinceEpoch,
          });
          await platform.invokeMethod('scheduleDndEndAt', {
            'endMillis': endTime.millisecondsSinceEpoch,
          });
          setState(() {
            status +=
                '⏰ Scheduled $subject ($day) ${_fmtTime(startTime)} → ${_fmtTime(endTime)} (At College)\n';
          });
        } else {
          setState(() {
            status +=
                '🏠 $subject ($day) ${_fmtTime(startTime)} → ${_fmtTime(endTime)} - Will check location at class time\n';
          });
          // Schedule a location check at class time
          _scheduleLocationCheckForClass(startTime, day, start, end, subject);
        }
      }
    } catch (e) {
      setState(() {
        status += '❌ Error $subject: $e\n';
      });
    }
  }

  Future<void> _scheduleDndForClass(Map<String, dynamic> classInfo) async {
    try {
      final startTime = classInfo['startTime'] as DateTime;
      final endTime = classInfo['endTime'] as DateTime;
      
      // Check if DND is already active
      await platform.invokeMethod('startDnd');
      await platform.invokeMethod('scheduleDndEndAt', {
        'endMillis': endTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error scheduling DND: $e');
    }
  }

  Future<void> _checkAndUpdateClassStatus({
    required String day,
    required String start,
    required String end,
    required String subject,
  }) async {
    final now = DateTime.now();
    final weekday = _weekdayFromString(day);
    DateTime classDate = _nextDateForWeekday(weekday);
    
    final sp = start.split(':').map(int.parse).toList();
    final ep = end.split(':').map(int.parse).toList();
    
    DateTime startTime = DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      sp[0],
      sp[1],
      sp.length > 2 ? sp[2] : 0,
    );
    
    DateTime endTime = DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      ep[0],
      ep[1],
      ep.length > 2 ? ep[2] : 0,
    );
    
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }
    
    // Check if class is active now
    final bool isClassActive = now.isAfter(startTime) && now.isBefore(endTime);
    
    if (isClassActive) {
      final classInfo = {
        'day': day,
        'start': start,
        'end': end,
        'subject': subject,
        'startTime': startTime,
        'endTime': endTime,
      };
      
      // Update active classes list
      final existingIndex = _activeClasses.indexWhere(
        (c) => c['subject'] == subject && c['day'] == day
      );
      
      if (existingIndex == -1) {
        _activeClasses.add(classInfo);
      } else {
        _activeClasses[existingIndex] = classInfo;
      }
      
      // Activate or cancel DND based on current location
      if (_isAtCollege) {
        await _scheduleDndForClass(classInfo);
      }
    } else {
      // Remove from active classes if class ended
      _activeClasses.removeWhere((c) => c['subject'] == subject && c['day'] == day);
    }
  }

  // Schedule a location check for when class is about to start
  void _scheduleLocationCheckForClass(DateTime startTime, String day, String start, String end, String subject) {
    final checkTime = startTime.subtract(const Duration(minutes: 5));
    final now = DateTime.now();
    
    if (checkTime.isAfter(now)) {
      Future.delayed(checkTime.difference(now), () async {
        final isAtCollege = await _isUserAtCollege();
        if (isAtCollege) {
          final ep = end.split(':').map(int.parse).toList();
          final classDate = startTime;
          
          DateTime endTime = DateTime(
            classDate.year,
            classDate.month,
            classDate.day,
            ep[0],
            ep[1],
            ep.length > 2 ? ep[2] : 0,
          );
          
          if (endTime.isBefore(startTime)) {
            endTime = endTime.add(const Duration(days: 1));
          }
          
          await platform.invokeMethod('scheduleDndStartAt', {
            'startMillis': startTime.millisecondsSinceEpoch,
          });
          await platform.invokeMethod('scheduleDndEndAt', {
            'endMillis': endTime.millisecondsSinceEpoch,
          });
          
          setState(() {
            status +=
                '📍 User arrived! Scheduled $subject ($day) ${_fmtTime(startTime)} → ${_fmtTime(endTime)}\n';
          });
        }
      });
    }
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _openDndSettings() async {
    await platform.invokeMethod('openDndSettings');
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable DND Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openDndSettings,
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(_hasLocationPermission ? Icons.location_on : Icons.location_off),
                if (_currentLocation != null && _isAtCollege)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _checkLocationPermission,
            tooltip: 'Location: ${_isAtCollege ? 'At College' : 'Not at College'}',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Real-time location status card
                  Card(
                    color: _isAtCollege ? Colors.green.shade50 : (_hasLocationPermission ? Colors.blue.shade50 : Colors.orange.shade50),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isAtCollege ? Icons.school : (_hasLocationPermission ? Icons.location_on : Icons.location_off),
                                color: _isAtCollege ? Colors.green : (_hasLocationPermission ? Colors.blue : Colors.orange),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isAtCollege 
                                        ? '✅ At College Campus' 
                                        : (_hasLocationPermission ? '📍 Tracking Location' : '⚠️ Location Access Needed'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isAtCollege ? Colors.green : (_hasLocationPermission ? Colors.blue : Colors.orange),
                                      ),
                                    ),
                                    if (_currentLocation != null)
                                      Text(
                                        '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                      ),
                                  ],
                                ),
                              ),
                              if (!_hasLocationPermission)
                                TextButton(
                                  onPressed: _checkLocationPermission,
                                  child: const Text('GRANT'),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _isAtCollege
                              ? 'DND will activate during active classes'
                              : 'DND paused - not at college location',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          if (_activeClasses.isNotEmpty && !_isAtCollege)
                            Text(
                              '${_activeClasses.length} active class(es) - DND disabled',
                              style: TextStyle(fontSize: 11, color: Colors.red.shade600, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: timings.length,
                      itemBuilder: (_, i) {
                        final t = timings[i];
                        return ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(t['subject']),
                          subtitle: Text('${t['day']} | ${t['start']} - ${t['to']}'),
                          trailing: _isClassActiveNow(t['day'], t['start'], t['to'])
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _isAtCollege ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _isAtCollege ? 'DND ON' : 'NO DND',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _isAtCollege ? Colors.green.shade800 : Colors.orange.shade800,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                  if (status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.indigo.shade50,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Live Updates:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _isAtCollege ? Colors.green : Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _isAtCollege ? 'AT COLLEGE' : 'NOT AT COLLEGE',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              status,
                              style: TextStyle(fontFamily: 'Monospace', fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () async {
              if (_hasLocationPermission) {
                final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.medium,
                );
                _handleNewLocation(position);
              }
            },
            child: const Icon(Icons.my_location),
            tooltip: 'Refresh Location',
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: fetchTimings,
            child: const Icon(Icons.refresh),
            tooltip: 'Refresh Timetable',
          ),
        ],
      ),
    );
  }

  bool _isClassActiveNow(String day, String start, String end) {
    try {
      final now = DateTime.now();
      final weekday = _weekdayFromString(day);
      DateTime classDate = _nextDateForWeekday(weekday);
      
      final sp = start.split(':').map(int.parse).toList();
      final ep = end.split(':').map(int.parse).toList();
      
      DateTime startTime = DateTime(
        classDate.year,
        classDate.month,
        classDate.day,
        sp[0],
        sp[1],
        sp.length > 2 ? sp[2] : 0,
      );
      
      DateTime endTime = DateTime(
        classDate.year,
        classDate.month,
        classDate.day,
        ep[0],
        ep[1],
        ep.length > 2 ? ep[2] : 0,
      );
      
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }
      
      return now.isAfter(startTime) && now.isBefore(endTime);
    } catch (e) {
      return false;
    }
  }
}