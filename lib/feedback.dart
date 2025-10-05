import 'package:flutter/material.dart';

class Feedbackk extends StatelessWidget {
  const Feedbackk({super.key});

  @override
  Widget build(BuildContext context) {
    final String replyText = 'Thank you for your feedback! We appreciate your input.';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Feedback',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // In case content overflows
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Feedback Input
            Text(
              'Feedback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Submit logic here
                },
                child: Text('Send'),
              ),
            ),

            // SizedBox(height: 30),x

            // Complaint Section
           
          ],
        ),
      ),
    );
  }
}
