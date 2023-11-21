import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  Future<dynamic> getToken(String email, String pass) async {
    try {
      var response = await Dio().post(
        'http://10.0.2.2:8000/api/login',
        data: {'email': email, 'password': pass},
      );
      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get('http://10.0.2.2:8000/api/user',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  Future<bool> registerUser(String username, String email, String pass) async {
    try {
      var user = await Dio().post("http://10.0.2.2:8000/api/register",
          data: {'name': username, 'email': email, 'password': pass});
      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  }

  // store booking details
  Future<dynamic> bookAppointments(
      String date, String day, String time, int doctor, String token) async {
    try {
      var response = await Dio().post('http://10.0.2.2:8000/api/book',
          data: {'date': date, 'day': day, 'time': time, 'doctor_id': doctor},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (e) {
      return e;
    }
  }

  // retrieve appointments
  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get('http://10.0.2.2:8000/api/appointments',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (e) {
      return e;
    }
  }

  // retrieve ratings
  Future<dynamic> getRatings(String token) async {
    try {
      var response = await Dio().get('http://10.0.2.2:8000/api/getreviews',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> StoreReviews(
      String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post('http://10.0.2.2:8000/api/reviews',
          data: {
            'ratings': ratings,
            'reviews': reviews,
            'appointment_id': id,
            'doctor_id': doctor
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (e) {
      return e;
    }
  }

  //store fav doctor
  Future<dynamic> storeFavDoc(String token, List<dynamic> favList) async {
    try {
      var response = await Dio().post('http://127.0.0.1:8000/api/fav',
          data: {
            'favList': favList,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //logout
  Future<dynamic> logout(String token) async {
    try {
      var response = await Dio().post('http://10.0.2.2:8000/api/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  // delete appointment

  Future<void> deleteEntry(int id, String token) async {
    // Replace with your Laravel API endpoint

    try {
      final response = await Dio().post(
          'http://10.0.2.2:8000/api/appointments/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        print('Entry deleted successfully');
      } else {
        print('Failed to delete entry. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to delete entry. Error: $error');
    }
  }
}
