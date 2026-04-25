import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/patients/add_patient_screen.dart';
import 'screens/patients/patient_list_screen.dart';
import 'screens/appointments/book_appointment_screen.dart';
import 'screens/appointments/appointment_list_screen.dart';
import 'screens/billing/generate_invoice_screen.dart';
import 'screens/billing/invoice_list_screen.dart';
import 'screens/pharmacy/add_medicine_screen.dart';
import 'screens/pharmacy/medicine_list_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/my_invoices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Homeopathy Clinic',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin_dashboard': (context) => const DashboardScreen(),
        '/patient_dashboard': (context) => const PatientDashboardScreen(),
        '/add_patient': (context) => const AddPatientScreen(),
        '/patients': (context) => const PatientListScreen(),
        '/book_appointment': (context) => const BookAppointmentScreen(),
        '/appointments': (context) => const AppointmentListScreen(),
        '/generate_invoice': (context) => const GenerateInvoiceScreen(),
        '/invoices': (context) => const InvoiceListScreen(),
        '/add_medicine': (context) => const AddMedicineScreen(),
        '/medicines': (context) => const MedicineListScreen(),
        '/my_appointments': (context) => const MyAppointmentsScreen(),
        '/my_invoices': (context) => const MyInvoicesScreen(),
      },
    );
  }
}