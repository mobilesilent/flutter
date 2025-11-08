// import 'package:automaticmb/complaint.dart';
// import 'package:automaticmb/feedback.dart';
// import 'package:automaticmb/loginscreen.dart';
// import 'package:automaticmb/timetable.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   final List<_HomeItem> items = [
//     _HomeItem(title: 'Timetable', icon: Icons.calendar_today, page: TimetableScreen()),
//     _HomeItem(title: 'Feedback', icon: Icons.feedback, page: Feedbackk()),
//     _HomeItem(title: 'Complaint', icon: Icons.report_problem, page: Complaint()),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Dashboard'),
//         centerTitle: true,
//       ),
//       drawer: Drawer(
//         child: Column(children: [
//           UserAccountsDrawerHeader(accountName: Text('Fathima Hiba K V'), accountEmail: Text('B08137')),
//           ListTile(title: Text('Logout'),
//           leading: Icon(Icons.logout),
//           onTap: () {
//             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Loginscreen(),), (route)=>false);
//           },)
//         ],),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: GridView.count(
//           crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
//           mainAxisSpacing: 20,
//           crossAxisSpacing: 20,
//           children: items.map((item) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context, MaterialPageRoute(builder: (_) => item.page));
//               },
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     color: Colors.indigo.shade50,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(item.icon, size: 50, color: Colors.indigo),
//                       SizedBox(height: 10),
//                       Text(
//                         item.title,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.indigo.shade800,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// class _HomeItem {
//   final String title;
//   final IconData icon;
//   final Widget page;

//   _HomeItem({required this.title, required this.icon, required this.page});
// }

// Placeholder Timetable Page

import 'package:automaticmb/dnd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:automaticmb/complaint.dart';
import 'package:automaticmb/feedback.dart';
import 'package:automaticmb/loginscreen.dart';
import 'package:automaticmb/timetable.dart';

const _channelName = 'com.example.automaticmb/dnd';

class HomePage extends StatelessWidget {
  final List<_HomeItem> items = [
    _HomeItem(
      title: 'Timetable',
      icon: Icons.calendar_today,
      page: TimetableScreen(),
    ),
    _HomeItem(title: 'Feedback', icon: Icons.feedback, page: Feedbackk()),
    _HomeItem(
      title: 'Complaint',
      icon: Icons.report_problem,
      page: Complaint(),
    ),
    _HomeItem(
      title: 'DND Scheduler',
      icon: Icons.do_not_disturb,
      page: TimetableScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard'), centerTitle: true),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Fathima Hiba K V'),
              accountEmail: Text('B08137'),
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Loginscreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: items.map((item) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.indigo.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 50, color: Colors.indigo),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final Widget page;

  _HomeItem({required this.title, required this.icon, required this.page});
}

//
// 🔹 DND Scheduler Page integrated as one of the home options
//
