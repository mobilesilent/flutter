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
