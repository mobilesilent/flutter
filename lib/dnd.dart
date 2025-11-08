import 'package:automaticmb/register.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTimings();
  }

  Future<void> fetchTimings() async {
    setState(() {
      isLoading = true;
      status = '';
    });

    try {
      final response = await _dio.get('$baseurl/timings_api/');
      print('Response: ${response.data}');

      if (response.statusCode == 200) {
        timings = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          isLoading = false;
        });

        // schedule for each timing
        for (final t in timings) {
          final String start = t['start'] ?? '';
          final String end = t['to'] ?? '';
          final String subject = t['subject'] ?? 'Class';
          if (start.isNotEmpty && end.isNotEmpty) {
            await _handleTiming(start, end, subject);
          }
        }
      } else {
        setState(() {
          isLoading = false;
          status = 'Failed to load timings: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        status = 'Error fetching timings: $e';
      });
    }
  }

  Future<void> _handleTiming(String start, String end, String subject) async {
    try {
      final now = DateTime.now();

      // parse "HH:mm:ss"
      final sp = start.split(':');
      final ep = end.split(':');

      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(sp[0]),
        int.parse(sp[1]),
        sp.length > 2 ? int.parse(sp[2]) : 0,
      );

      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(ep[0]),
        int.parse(ep[1]),
        ep.length > 2 ? int.parse(ep[2]) : 0,
      );

      // if end is before start, treat as next day end (optional)
      DateTime finalEndTime = endTime;
      if (endTime.isBefore(startTime)) {
        finalEndTime = endTime.add(const Duration(days: 1));
      }

      if (now.isAfter(startTime) && now.isBefore(finalEndTime) ||
          now.isAtSameMomentAs(startTime)) {
        // inside period: start immediately and schedule end
        try {
          await platform.invokeMethod('startDnd');
          await platform.invokeMethod('scheduleDndEndAt', {
            'endMillis': finalEndTime.millisecondsSinceEpoch,
          });
          setState(() {
            status +=
                '🔴 DND started for $subject until ${_fmtTime(finalEndTime)}\n';
          });
        } catch (e) {
          setState(() {
            status += 'Error starting DND for $subject: $e\n';
          });
        }
      } else if (now.isBefore(startTime)) {
        // future: schedule start and schedule end
        try {
          await platform.invokeMethod('scheduleDndStartAt', {
            'startMillis': startTime.millisecondsSinceEpoch,
          });
          await platform.invokeMethod('scheduleDndEndAt', {
            'endMillis': finalEndTime.millisecondsSinceEpoch,
          });
          setState(() {
            status +=
                '⏰ Scheduled $subject ${_fmtTime(startTime)} → ${_fmtTime(finalEndTime)}\n';
          });
        } catch (e) {
          setState(() {
            status += 'Error scheduling DND for $subject: $e\n';
          });
        }
      } else {
        // already passed
        setState(() {
          status += '⏭ Skipped $subject (time passed)\n';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        status += 'Platform error: ${e.message}\n';
      });
    } catch (e) {
      setState(() {
        status += 'Generic error: $e\n';
      });
    }
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _openDndSettings() async {
    try {
      await platform.invokeMethod('openDndSettings');
    } catch (e) {
      setState(() {
        status += 'Cannot open settings: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable DND Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openDndSettings,
            tooltip: 'Open DND Settings (grant permission)',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: timings.isEmpty
                        ? const Center(child: Text('No timings'))
                        : ListView.builder(
                            itemCount: timings.length,
                            itemBuilder: (context, i) {
                              final t = timings[i];
                              return ListTile(
                                leading: const Icon(Icons.schedule),
                                title: Text(t['subject'] ?? ''),
                                subtitle: Text(
                                  '${t['day']} | ${t['start']} - ${t['to']}',
                                ),
                              );
                            },
                          ),
                  ),
                  if (status.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.indigo.shade50,
                      child: SingleChildScrollView(child: Text(status)),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: fetchTimings,
        tooltip: 'Refresh timings & schedule',
      ),
    );
  }
}
