import 'package:doctor_appointment/components/custom_AppBar.dart';
import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../components/doctor_card.dart';

class DoctorCategories extends StatefulWidget {
  String category;
  DoctorCategories({Key? key, required this.category}) : super(key: key);

  @override
  State<DoctorCategories> createState() => _DoctorCategoriesState();
}

class _DoctorCategoriesState extends State<DoctorCategories> {
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthModel>(context, listen: false).getUser;

    List<dynamic> filteredDoctors = user['doctor'].where((doctor) {
      return widget.category == doctor['category'];
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: widget.category,
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: Container(
          child: Column(
        children: List.generate(filteredDoctors.length, (index) {
          return DoctorCard(
            doctor: filteredDoctors[index],
            isFav: favList.contains(filteredDoctors[index]['doc_id']),
          );
        }),
      )),
    );
  }
}
