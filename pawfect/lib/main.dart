import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pawfect/admin/home.dart';
import 'package:pawfect/admin/manageproduct.dart';
import 'package:pawfect/admin/manageveterians.dart';
import 'package:pawfect/admin/mangeusers.dart';
import 'package:pawfect/shelter/addproduct.dart';
import 'package:pawfect/shelter/addshelter.dart';
import 'package:pawfect/shelter/home.dart';
import 'package:pawfect/shelter/manageproduct.dart';
import 'package:pawfect/shelter/manageshelter.dart';
import 'package:pawfect/users/Manage_blogs.dart';
import 'package:pawfect/users/health_track.dart';
import 'package:pawfect/users/manage_appoinments.dart';
import 'package:pawfect/users/managepets.dart';
import 'package:pawfect/users/pet_store.dart';
import 'package:pawfect/users/user_feedback.dart';
import 'package:pawfect/users/user_profile.dart';
import 'package:pawfect/vetinarian/add_health.dart';
import 'package:pawfect/vetinarian/emergency.dart';
import 'package:pawfect/vetinarian/home.dart';
import 'package:pawfect/vetinarian/manage_helalth.dart';
import 'package:pawfect/vetinarian/mange_appointments.dart';
import 'firebase_options.dart';
import '../auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Define brand colors
    const Color blue = Color(0xFF1E3062);
    const Color green = Color(0xFF00B14F);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Care App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,

        // ✅ Color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          secondary: green,
        ),

        // ✅ Input field styling (TextFields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: blue),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: blue, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: green, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // ✅ Button styling (all ElevatedButtons)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: green, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ✅ TextButton styling (for links like "Forgot Password")
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: blue,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      home: const LoginScreen(),

      routes: {
        '/profile': (context) => ManageProfilePage(),
        '/pets': (context) => Managepets(),
        '/health': (context) => HealthTrack(),
        '/appointments': (context) => ManageAppoinments(),
        '/petstore': (context) => PetStore(),
        '/myblogs': (context) => ManageBlogs(),
        '/feedback': (context) => UserFeedback(),
        '/dashboard': (context) => AdminDashboard(),
        '/users': (context) => UsersPage(),
        '/Vets': (context) => VeterinariansPage(),
        '/shelters': (context) => AddShelterPage(),
        '/products': (context) => ProductsPage(),
        '/shelterdash': (context) => ShelterDashboard(),
        '/add-product': (context) => AddProductPage(),
        '/add-shelter': (context) => AddShelterPage(),
        '/shelter-manage': (context) => ManageSheltersPage(),
        '/shelter-products': (context) => ManageProductsPage(),
        '/vet-health': (context) => const HealthRecordsPage(),
        '/vet-appointments': (context) => const AppointmentsPage(),
        '/vet-emergency': (context) => const EmergencyPage(),
        '/add-health-record': (context) => const AddHealthRecordPage(),
        '/vet-home': (context) => const VeterinarianHomeScreen(),
      },
    );
  }
}
