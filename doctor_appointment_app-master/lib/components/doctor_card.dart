import 'dart:ui';

import 'package:doctor_appointment/main.dart';
import 'package:doctor_appointment/screens/doctor_details.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment/utils/config.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({Key? key, required this.doctor, required this.isFav})
      : super(key: key);

  final Map<String, dynamic> doctor; // recieve doctor details
  final bool isFav;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: Config.widthSize * 0.33,
                child: Image.network(
                  "http://10.0.2.2:8000${doctor['doctor_profile']}",
                  fit: BoxFit.fill,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        "DR.${doctor['doctor_name']}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${doctor['category']}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        "${doctor['bio_data']}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          MyApp.navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (_) => DoctorDetails(
                    doctor: doctor,
                    isFav: isFav,
                  )));
        },
      ),
    );
  }
}
