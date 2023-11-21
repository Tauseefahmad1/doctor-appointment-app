/*import 'package:doctor_appointment/components/button.dart';
import 'package:doctor_appointment/main.dart';
import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:doctor_appointment/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';*/
/*class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}*/
/*
class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passController = TextEditingController();
  bool _obsecureText = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            keyboardType: TextInputType.text,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
                hintText: "User Name",
                labelText: "User Name",
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.person_outlined,
                ),
                prefixIconColor: Config.primaryColor),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
                hintText: "Email Address",
                labelText: "Email",
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                prefixIconColor: Config.primaryColor),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: _obsecureText,
            decoration: InputDecoration(
                hintText: "PassWord",
                labelText: "Password",
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.lock_outline,
                ),
                prefixIconColor: Config.primaryColor,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obsecureText = !_obsecureText;
                    });
                  },
                  icon: _obsecureText
                      ? Icon(
                          Icons.visibility_off_outlined,
                          color: Colors.black38,
                        )
                      : Icon(
                          Icons.visibility_outlined,
                          color: Colors.greenAccent,
                        ),
                )),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(builder: (context, auth, child) {
            return Button(
                width: double.infinity,
                title: "Sign Up",
                onPressed: () async {
                  final userRegisteration = await DioProvider().registerUser(
                      nameController.text,
                      emailController.text,
                      passController.text);
                  if (userRegisteration) {
                    final token = await DioProvider()
                        .getToken(emailController.text, passController.text);
                    if (token) {
                      auth.loginSuccess({}, {});
                      MyApp.navigatorKey.currentState!.pushNamed('main');
                    }
                  } else {}

                  */
/* */ /*

                },
                disable: false);
          })
        ],
      ),
    );
  }
}
*/

import 'dart:convert';

import 'package:doctor_appointment/components/button.dart';
import 'package:doctor_appointment/main.dart';
import 'package:doctor_appointment/models/auth_model.dart';
import 'package:doctor_appointment/providers/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Username',
              labelText: 'Username',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lock_outline),
                prefixIconColor: Config.primaryColor,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecurePass = !obsecurePass;
                      });
                    },
                    icon: obsecurePass
                        ? const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.black38,
                          )
                        : const Icon(
                            Icons.visibility_outlined,
                            color: Config.primaryColor,
                          ))),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return Button(
                width: double.infinity,
                title: 'Sign Up',
                onPressed: () async {
                  final userRegistration = await DioProvider().registerUser(
                      _nameController.text,
                      _emailController.text,
                      _passController.text);

                  //if register success, proceed to login
                  if (userRegistration) {
                    final token = await DioProvider()
                        .getToken(_emailController.text, _passController.text);

                    if (token) {
                      //auth.loginSuccess(); //update login status
                      //rediret to main page

                      //grab user data here
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      final tokenValue = prefs.getString('token') ?? '';

                      if (tokenValue.isNotEmpty && tokenValue != '') {
                        //get user data
                        final response =
                            await DioProvider().getUser(tokenValue);
                        if (response != null) {
                          setState(() {
                            //json decode
                            Map<String, dynamic> appointment = {};
                            final user = json.decode(response);

                            //check if any appointment today
                            for (var doctorData in user['doctor']) {
                              //if there is appointment return for today

                              if (doctorData['appointments'] != null) {
                                appointment = doctorData;
                              }
                            }

                            auth.loginSuccess(user, appointment);
                            MyApp.navigatorKey.currentState!.pushNamed('main');
                          });
                        }
                      }
                    }
                  } else {
                    print('register not successful');
                  }
                },
                disable: false,
              );
            },
          )
        ],
      ),
    );
  }
}
