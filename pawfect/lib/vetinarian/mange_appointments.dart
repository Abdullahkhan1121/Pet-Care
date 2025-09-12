import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfect/vetinarian/theme.dart';
import 'package:pawfect/vetinarian/vet_appbar.dart';
import 'vet_drawer.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  void approveAppointment(String id) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'status': 'approved'});
  }

  void rejectAppointment(String id) {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'status': 'rejected'});
  }

  void suggestDates(String id) {
    FirebaseFirestore.instance.collection('appointments').doc(id).update({
      'suggestedDates': ['2025-09-15', '2025-09-17', '2025-09-19'],
      'status': 'waiting-user',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VetAppBar(title: "Appointments"),
      drawer: const VetDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final appointments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appt = appointments[index];
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: VetTheme.cardDecoration(),
                child: ListTile(
                  title: Text("Pet: ${appt['petName']}"),
                  subtitle: Text("Date: ${appt['date']} | Status: ${appt['status']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => approveAppointment(appt.id)),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => rejectAppointment(appt.id)),
                      IconButton(
                          icon: const Icon(Icons.calendar_month,
                              color: Colors.blue),
                          onPressed: () => suggestDates(appt.id)),
                    ],
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
