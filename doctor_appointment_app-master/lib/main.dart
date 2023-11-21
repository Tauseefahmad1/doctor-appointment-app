import 'dart:ui';

import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/screens/appointment_page.dart';
import 'package:doctor_appointment/screens/authPage.dart';
import 'package:doctor_appointment/screens/doctor_details.dart';
import 'package:doctor_appointment/screens/success_booking.dart';
import 'package:doctor_appointment/utils/main_layOut.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/config.dart';
import 'screens/booking_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Doctor Appointment App',
        theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
                focusColor: Config.primaryColor,
                border: Config.outlinedBorder,
                focusedBorder: Config.focusBorder,
                errorBorder: Config.errorBorder,
                enabledBorder: Config.outlinedBorder,
                floatingLabelStyle: TextStyle(color: Config.primaryColor),
                prefixIconColor: Colors.black38),
            scaffoldBackgroundColor: Colors.white,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Config.primaryColor,
                selectedItemColor: Colors.white,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                unselectedItemColor: Colors.grey.shade700,
                elevation: 10,
                type: BottomNavigationBarType.fixed)),
        initialRoute: '/',
        routes: {
          //intial routes for login signup
          '/': (context) => AuthPage(),
          //main layout after login signup
          'main': (context) => MainLayOut(),
          /*'doc_details': (context) => DoctorDetails(),*/
          'booking_page': (context) => BookingPage(),
          'success_booking': (context) => AppointmentBooked()
        },
      ),
    );
  }
}
