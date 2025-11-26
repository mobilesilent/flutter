// import 'package:flutter/material.dart';


// class TimetableScreen extends StatelessWidget {
//   // Time slots
//   final List<String> timeSlotsMonToThu = [
//     '9:00 - 9:55',
//     '9:55 - 10:50',
//     'Break\n10:50 - 11:10',
//     '11:10 - 12:05',
//     '12:05 - 1:00',
//     'Lunch\n1:00 - 2:00',
//     '2:00 - 3:00',
//   ];

//   final List<String> timeSlotsFriday = [
//     '9:00 - 9:50',
//     '9:50 - 10:45',
//     'Break\n10:45 - 11:00',
//     '11:00 - 11:50',
//     '11:50 - 12:30',
//     'Lunch\n12:30 - 1:50',
//     '1:50 - 3:00',
//   ];

//   // Subjects
//   final Map<String, List<String>> subjectsMonToThu = {
//     'Monday': ['Math', 'Science', '', 'English', 'History', '', 'PE'],
//     'Tuesday': ['English', 'Math', '', 'Science', 'Geography', '', 'Art'],
//     'Wednesday': ['History', 'Math', '', 'Computer', 'English', '', 'PE'],
//     'Thursday': ['Science', 'Math', '', 'Art', 'Computer', '', 'Music'],
//   };

//   final List<String> fridaySubjects = ['Math', 'Science', '', 'English', 'History', '', 'PE'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Weekly Class Timetable'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.all(16),
//         child: Card(
//           elevation: 8,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Table(
//               border: TableBorder.all(color: Colors.grey.shade300),
//               defaultColumnWidth: FixedColumnWidth(140),
//               children: [
//                 // Header row for Mon–Thu
//                 TableRow(
//                   decoration: BoxDecoration(color: Colors.indigo.shade100),
//                   children: [
//                     buildHeaderCell('Day / Time'),
//                     for (var time in timeSlotsMonToThu)
//                       buildHeaderCell(time),
//                   ],
//                 ),

//                 // Monday to Thursday rows
//                 for (var day in subjectsMonToThu.keys)
//                   TableRow(
//                     children: [
//                       buildDayCell(day),
//                       for (var subject in subjectsMonToThu[day]!)
//                         buildSubjectCell(subject),
//                     ],
//                   ),

//                 // Spacer row before Friday header
//                 TableRow(
//                   children: [
//                     for (int i = 0; i <= timeSlotsFriday.length; i++)
//                       Container(height: 12),
//                   ],
//                 ),

//                 // Header row for Friday
//                 TableRow(
//                   decoration: BoxDecoration(color: Colors.indigo.shade100),
//                   children: [
//                     buildHeaderCell('Day / Time'),
//                     for (var time in timeSlotsFriday)
//                       buildHeaderCell(time),
//                   ],
//                 ),

//                 // Friday data row
//                 TableRow(
//                   children: [
//                     buildDayCell('Friday'),
//                     for (var subject in fridaySubjects)
//                       buildSubjectCell(subject),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Reusable cell builders
//   Widget buildHeaderCell(String text) => Container(
//         padding: EdgeInsets.all(10),
//         alignment: Alignment.center,
//         child: Text(
//           text,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           textAlign: TextAlign.center,
//         ),
//       );

//   Widget buildDayCell(String text) => Container(
//         padding: EdgeInsets.all(10),
//         color: Colors.indigo.shade50,
//         alignment: Alignment.center,
//         child: Text(
//           text,
//           style: TextStyle(fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//       );

//   Widget buildSubjectCell(String text) {
//     final isBreakOrLunch = text.trim().isEmpty;
//     return Container(
//       padding: EdgeInsets.all(10),
//       color: isBreakOrLunch ? Colors.grey.shade100 : null,
//       alignment: Alignment.center,
//       child: Text(
//         isBreakOrLunch ? '-' : text,
//         style: TextStyle(
//           fontStyle: isBreakOrLunch ? FontStyle.italic : FontStyle.normal,
//           color: isBreakOrLunch ? Colors.grey : Colors.black,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

import 'package:automaticmb/register.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:automaticmb/loginscreen.dart';

class ViewTimetablePage extends StatefulWidget {
  const ViewTimetablePage({super.key});

  @override
  State<ViewTimetablePage> createState() => _ViewTimetablePageState();
}

class _ViewTimetablePageState extends State<ViewTimetablePage> {
  late Future<List<Timetable>> timetableFuture;

  @override
  void initState() {
    super.initState();
    timetableFuture = fetchTimetable(loginid!);
  }

  Future<List<Timetable>> fetchTimetable(int lid) async {
    try {
      final response = await Dio().get("$baseurl/ViewTimeTable/$lid");
      return (response.data as List)
          .map((json) => Timetable.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Failed to load timetable: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timetable"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Timetable>>(
        future: timetableFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("No timetable found"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;

              // FIXED table width (needed for scaling)
              double tableWidth = 600;

              // Auto scale factor so whole table fits screen
              double scaleFactor = screenWidth / tableWidth;

              return InteractiveViewer(
                minScale: scaleFactor, // so it stays fully visible
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(100),

                child: Transform.scale(
                  scale: scaleFactor,
                  alignment: Alignment.topLeft,

                  child: SizedBox(
                    width: tableWidth,
                    child: DataTable(
                      columnSpacing: 30,
                      border: TableBorder.all(color: Colors.black26),
                      columns: const [
                        DataColumn(label: Text("Day", style: boldStyle)),
                        DataColumn(label: Text("9–10", style: boldStyle)),
                        DataColumn(label: Text("10–11", style: boldStyle)),
                        DataColumn(label: Text("11–12", style: boldStyle)),
                        DataColumn(label: Text("12–1", style: boldStyle)),
                        DataColumn(label: Text("2–3", style: boldStyle)),
                      ],
                      rows: data.map((t) {
                        return DataRow(
                          cells: [
                            DataCell(Text(t.day)),
                            DataCell(Text(t.subject1)),
                            DataCell(Text(t.subject2)),
                            DataCell(Text(t.subject3)),
                            DataCell(Text(t.subject4)),
                            DataCell(Text(t.subject5)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

const boldStyle = TextStyle(fontWeight: FontWeight.bold);

class Timetable {
  final String day;
  final String subject1;
  final String subject2;
  final String subject3;
  final String subject4;
  final String subject5;

  Timetable({
    required this.day,
    required this.subject1,
    required this.subject2,
    required this.subject3,
    required this.subject4,
    required this.subject5,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      day: json["day"] ?? "",
      subject1: json["subject1"] ?? "",
      subject2: json["subject2"] ?? "",
      subject3: json["subject3"] ?? "",
      subject4: json["subject4"] ?? "",
      subject5: json["subject5"] ?? "",
    );
  }
}
