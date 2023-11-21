import 'dart:convert';
import 'dart:ui';
import 'package:doctor_appointment/components/appointment_card.dart';
import 'package:doctor_appointment/components/doctor_card.dart';
import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:doctor_appointment/screens/categories_doctor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> doctor = {};
  List<dynamic> favList = [];
  List<Map<String, dynamic>> medCat = [
    {"icon": FontAwesomeIcons.userDoctor, "category": "General"},
    {"icon": FontAwesomeIcons.heartPulse, "category": "Cardiology"},
    {"icon": FontAwesomeIcons.lungs, "category": "Respirations"},
    {"icon": FontAwesomeIcons.hands, "category": "Dermatology"},
    {"icon": FontAwesomeIcons.personPregnant, "category": "Gynecology"},
    {"icon": FontAwesomeIcons.teeth, "category": "Dentist"}
  ];

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    user = Provider.of<AuthModel>(context, listen: false).getUser;
    doctor = Provider.of<AuthModel>(context, listen: false).getAppointments;
    favList = Provider.of<AuthModel>(context, listen: false).getFav;
    return Scaffold(
      body: user.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user['name'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage("assets/fb.png"),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            width: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(16)),
                              child: IconButton(
                                  onPressed: () async {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    final token =
                                        prefs.getString('token') ?? '';
                                    if (token.isNotEmpty && token != '') {
                                      final response =
                                          await DioProvider().logout(token);
                                      if (response == 200) {
                                        await prefs.remove('token');
                                        setState(() {
                                          MyApp.navigatorKey.currentState!
                                              .pushReplacementNamed('/');
                                        });
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                            ),
                          )
                        ],
                      ),
                      Config.spaceMedium,
                      //categroy listing
                      Text("Category",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      SizedBox(
                        height: Config.heightSize * 0.05,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List<Widget>.generate(
                            medCat.length,
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  MyApp.navigatorKey.currentState!
                                      .push(MaterialPageRoute(
                                          builder: (_) => DoctorCategories(
                                                category: medCat[index]
                                                    ['category'],
                                              )));
                                },
                                child: Card(
                                  margin: EdgeInsets.only(right: 20),
                                  color: Config.primaryColor,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        FaIcon(
                                          medCat[index]['icon'],
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          medCat[index]['category'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Config.spaceSmall,
                      Text("Appointment Today",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      //appoint card
                      doctor.isNotEmpty
                          ? AppointmentCard(
                              doctor: doctor,
                              color: Config.primaryColor,
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "No Appointments",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                      Config.spaceSmall,
                      Text("Top Doctors",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      Column(
                        children: List.generate(user['doctor'].length, (index) {
                          return DoctorCard(
                            /*  route: 'doc_details',*/
                            doctor: user['doctor'][index],
                            isFav: favList
                                    .contains(user['doctor'][index]['doc_id'])
                                ? true
                                : false,
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
