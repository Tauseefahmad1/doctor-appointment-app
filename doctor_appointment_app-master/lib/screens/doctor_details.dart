import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:doctor_appointment/components/button.dart';
import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_appointment/components/custom_AppBar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDetails extends StatefulWidget {
  const DoctorDetails({Key? key, required this.doctor, required this.isFav})
      : super(key: key);
  final Map<String, dynamic> doctor;
  final bool isFav;
  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  Map<String, dynamic> doctor = {};
  List<dynamic> RRatings = [];
  Future<void> getRate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token') ?? '';

    try {
      final Ratings = await DioProvider().getRatings(token);

      if (Ratings != 'Error') {
        setState(() {
          RRatings = json.decode(Ratings);
        });

        print('RRatings: ${RRatings}');
      }
    } on DioException catch (e) {
      // Handle DioException
      print('DioException: ${e.message}');
    } catch (e) {
      // Handle other exceptions
      print('Error retrieving ratings: $e');
    }
  }

  bool isFav = false;
  @override
  void initState() {
    doctor = widget.doctor;
    isFav = widget.isFav;
    getRate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*final doctor = ModalRoute.of(context)!.settings.arguments as Map;*/
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Doctor Details",
        icon: FaIcon(Icons.arrow_back_ios),
        actions: [
          IconButton(
            //press this button to add/remove favorite doctor
            onPressed: () async {
              setState(() {});
              //get latest favorite list from auth model
              final list =
                  Provider.of<AuthModel>(context, listen: false).getFav;

              //if doc id is already exist, mean remove the doc id
              if (list.contains(doctor['doc_id'])) {
                list.removeWhere((id) => id == doctor['doc_id']);
              } else {
                //else, add new doctor to favorite list
                list.add(doctor['doc_id']);
              }

              //update the list into auth model and notify all widgets
              Provider.of<AuthModel>(context, listen: false).setFavList(list);

              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final token = prefs.getString('token') ?? '';

              if (token.isNotEmpty && token != '') {
                //update the favorite list into database
                final response = await DioProvider().storeFavDoc(token, list);
                //if insert successfully, then change the favorite status

                if (response == 200) {
                  setState(() {
                    isFav = !isFav;
                  });
                }
              }
            },
            icon: FaIcon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AboutDoctor(
              doctor: doctor,
            ),
            DetailBody(
              doctor: doctor,
              RRatings: RRatings,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Button(
                width: double.infinity,
                title: "Book Appointment",
                onPressed: () {
                  //passing doc_id for booking process
                  Navigator.of(context).pushNamed('booking_page',
                      arguments: {"doctor_id": doctor['doc_id']});
                },
                disable: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({Key? key, required this.doctor}) : super(key: key);
  final Map<dynamic, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.0,
            backgroundImage:
                NetworkImage("http://10.0.2.2:8000${doctor['doctor_profile']}"),
          ),
          Config.spaceMedium,
          Text(
            "DR.${doctor['doctor_name']}",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              "${doctor['bio_data']}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              "Margella Dentist Hospital",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  DetailBody({Key? key, required this.doctor, required this.RRatings})
      : super(key: key);
  final Map<dynamic, dynamic> doctor;
  List<dynamic> RRatings;

  double calculateAverageRating(List<dynamic> rratings, Map doctor) {
    // Filter the rratings list to only include items with the specified doctorId
    List<dynamic> filteredRatings =
        rratings.where((item) => item['doc_id'] == doctor['doc_id']).toList();

    if (filteredRatings.isEmpty) {
      return 0.0; // Return 0 if there are no ratings for the specified doctorId
    }

    // Calculate the sum of ratings
    double sum = filteredRatings.fold(
        0, (previousValue, element) => previousValue + element['ratings']);

    // Calculate the average rating
    double averageRating = sum / filteredRatings.length;

    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    //get arguments passed from doc car
    double averageRating = double.parse(
        calculateAverageRating(RRatings, doctor).toStringAsFixed(1));

    Config().init(context);
    return Container(
      padding: EdgeInsets.all(10),
      /* margin: EdgeInsets.only(bottom: 1),*/
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Config.spaceSmall,
          DetailInfo(
            patients: doctor['patients'],
            exp: doctor['experience'],
            ratings: averageRating,
          ),
          Config.spaceSmall,
          Text(
            "About Doctor",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceSmall,
          Text(
            "${doctor['category']}  ${doctor['doctor_name']} ${doctor['bio_data']}",
            style: TextStyle(fontWeight: FontWeight.w500, height: 1.5),
            softWrap: true,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

class DetailInfo extends StatelessWidget {
  const DetailInfo({
    Key? key,
    required this.patients,
    required this.exp,
    required this.ratings,
  }) : super(key: key);

  final int patients;
  final int exp;
  final double ratings;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InfoCard(
          label: "Patient",
          value: "$patients",
        ),
        const SizedBox(
          width: 15,
        ),
        InfoCard(
          label: "Experience",
          value: "$exp years",
        ),
        const SizedBox(
          width: 15,
        ),
        InfoCard(label: "Rating", value: "$ratings"),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key, required this.label, required this.value})
      : super(key: key);

  final String? label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Config.primaryColor),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          children: [
            Text(
              label!,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              value!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800),
            )
          ],
        ),
      ),
    );
  }
}
