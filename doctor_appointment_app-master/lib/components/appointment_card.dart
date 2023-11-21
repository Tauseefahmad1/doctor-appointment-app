import 'dart:ui';
import 'package:doctor_appointment/main.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({Key? key, required this.doctor, required this.color})
      : super(key: key);
  final Map<String, dynamic> doctor;
  final Color color;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(10)),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        'http://10.0.2.2:8000${widget.doctor['doctor_profile']}'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${widget.doctor['doctor_name']}",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        widget.doctor['category'],
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  )
                ],
              ),
              Config.spaceSmall,
              //scheduleInfo
              ScheduleCard(
                appointments: widget.doctor['appointments'],
              ),
              Config.spaceSmall,
              //actionButtons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Cancel Appointment?"),
                                content: Text(
                                    "Do you Really Want to Cancel Appointment?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Perform an action when the "Cancel" button is pressed
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      final token =
                                          prefs.getString('token') ?? '';
                                      await DioProvider().deleteEntry(
                                          widget.doctor['appointments']['id'],
                                          token);
                                      await MyApp.navigatorKey.currentState!
                                          .pushNamed('main');
                                      setState(() {});
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return RatingDialog(
                                  initialRating: 1.0,
                                  title: Text(
                                    "Rate the Doctor",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  message: Text(
                                    'Please help us to rate our doctor',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  image: Icon(
                                    Icons.medical_services_outlined,
                                    color: Colors.greenAccent,
                                    size: 100,
                                  ),
                                  submitButtonText: "Submit",
                                  commentHint: 'Your Reviews',
                                  onSubmitted: (response) async {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    final token =
                                        prefs.getString('token') ?? '';
                                    final rating = await DioProvider()
                                        .StoreReviews(
                                            response.comment,
                                            response.rating,
                                            widget.doctor['appointments']['id'],
                                            widget.doctor['doc_id'],
                                            token);
                                    if (rating == 200 && rating != '') {
                                      MyApp.navigatorKey.currentState!
                                          .pushNamed('main');
                                    }
                                  });
                            });
                      },
                      child: Text(
                        "Completed",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//scheduleWidget
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key, required this.appointments}) : super(key: key);
  final Map<String, dynamic> appointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "${appointments['day']}, ${appointments['date']}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              appointments['time'],
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
