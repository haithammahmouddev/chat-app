import 'package:flutter/material.dart';
import 'package:whats_app/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/presentation/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding:const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50,),
                const Text('Welcome To WhatsApp',style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600
                ),),
              const SizedBox(height: 50,),
                Image.asset(
                  'assets/images/bg.png',
                  height: 340,
                  width: 340,
                  color: tabColor,
                ),
                SizedBox(height: size.height/9,),
                const Text('Read our Privacy. Tap "Agree and continue" to accept the terms of Service.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: greyColor,
                  ),
                ),
               const SizedBox(height: 10,),
                SizedBox(
                  width: size.width*0.75,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
                    },
                    text: 'AGREE AND CONTINUE',),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          )
      ),
    );
  }
}
