import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:doctor_appointment/components/custom_AppBar.dart';
import 'package:doctor_appointment/models/Booking_date_time_converter.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_appointment/components/button.dart';

import '../main.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime focusDay = DateTime.now();
  DateTime currentDay = DateTime.now();
  int? currentIndex;
  bool isWeekend = false;
  bool? dateSelected = false;
  bool? timeSelected = false;

  String? token; //get token to insert booking date

  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    // TODO: implement initState
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ModalRoute.of(context)!.settings.arguments as Map;
    Config().init(context);
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Appointment",
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                //display table calender here
                _tableCalender(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      "Select Consultation Time",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    alignment: Alignment.center,
                    child: Text(
                      "Weekend is not avalible please select Another date . Thank You!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          //when selected,update current index and set time selected tot true
                          currentIndex = index;
                          timeSelected = true;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: currentIndex == index
                                    ? Colors.white
                                    : Colors.black),
                            borderRadius: BorderRadius.circular(15),
                            color: currentIndex == index
                                ? Config.primaryColor
                                : null),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  currentIndex == index ? Colors.white : null),
                        ),
                      ),
                    );
                  }, childCount: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                  width: double.infinity,
                  title: "Make Appointment",
                  onPressed: () async {
                    //convert day/date/time
                    final getDate = DateConverted.getDate(currentDay);
                    final getDay = DateConverted.getDay(currentDay.weekday);
                    final getTime = DateConverted.getTime(currentIndex!);
                    final booking = await DioProvider().bookAppointments(
                        getDate, getDay, getTime, doctor['doctor_id'], token!);
                    if (booking == 200) {
                      MyApp.navigatorKey.currentState!
                          .pushNamed("success_booking");
                    }
                  },
                  disable: timeSelected! && dateSelected! ? false : true),
            ),
          )
        ],
      ),
    );
  }

  Widget _tableCalender() {
    return TableCalendar(
      focusedDay: focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2023, 12, 31),
      calendarFormat: _format,
      currentDay: currentDay,
      rowHeight: 48,
      calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
              color: Config.primaryColor, shape: BoxShape.circle)),
      availableCalendarFormats: {CalendarFormat.month: 'Month'},
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (((selectedDay, focusedDay) {
        setState(() {
          currentDay = selectedDay;
          focusDay = focusedDay;
          dateSelected = true;

          //check if weekend selected
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            isWeekend = true;
            timeSelected = false;
            currentIndex = null;
          } else {
            isWeekend = false;
          }
        });
      })),
    );
  }
}
