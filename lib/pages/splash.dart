import 'package:flutter/material.dart';
import 'package:health_track/loginPage.dart';
class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Loginpage()));
    });
    return Scaffold(
      body: Column(
        children: [
          Image.network("images/IMG-20190224-WA0012.jpg")
        ],
      ),
    );
  }
}