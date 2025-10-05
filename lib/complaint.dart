import 'package:flutter/material.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class ComplaintItem {
  final String complaint;
  String? reply;
  ComplaintItem({required this.complaint, this.reply});
}

class _ComplaintState extends State<Complaint> {
  final TextEditingController _complaintController = TextEditingController();
  final List<ComplaintItem> _complaints = [];

  void _submitComplaint() {
    final text = _complaintController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complaint')),
      );
      return;
    }

    // Add new complaint with empty reply
    setState(() {
      _complaints.add(ComplaintItem(complaint: text));
      _complaintController.clear();
    });

    // Simulate backend reply fetching with delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _complaints.last.reply = "This is a reply from backend for: \"$text\"";
      });
    });
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Complaint',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Submit a Complaint',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Describe your complaint below and see replies.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Complaint input
                TextFormField(
                  controller: _complaintController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Complaint',
                    hintText: 'Write your complaint here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.brown, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      
                    ),
                    child: const Text(
                      'Submit Complaint',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color:Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (_complaints.isNotEmpty) ...[
                  const Text(
                    'Complaints & Replies',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _complaints.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final complaintItem = _complaints[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complaint:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              complaintItem.complaint,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Reply:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            const SizedBox(height: 6),
                            complaintItem.reply == null
                                ? const Text(
                                    'Fetching reply...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Text(
                                    complaintItem.reply!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ],
                        ),
                      );
                    },
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
