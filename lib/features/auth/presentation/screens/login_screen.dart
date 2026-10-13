import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/colors.dart';
import 'package:whats_app/core/widgets/custom_button.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../core/di/injection_container.dart';
import '../controllers/phone_auth_controller/phone_auth_bloc.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Country? country;

  @override
  void initState() {
    phoneController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => sl<PhoneAuthBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter your phone number'),
          elevation: 0,
          backgroundColor: backgroundColor,
        ),
        body: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
          listener: (context, state) {
            if (state is PhoneNumberVerificationFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ));
            }

            if (state is PhoneCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم إرسال الرمز بنجاح'),
                backgroundColor: Colors.green,
              ));
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return BlocProvider.value(value: context.read<PhoneAuthBloc>(),
                child: OtpScreen(
                  verificationId: state.verificationId,
                  resendToken: state.resendToken,
                  phoneNumber:
                  '+${country!.phoneCode}${phoneController.text.trim()}',
                ),
                );
              }));
            }
          },
          builder: (context, state) {
            final loading = state is PhoneNumberVerifying;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'WhatsApp will need to verify your phone number'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country selectedCountry) {
                            setState(() {
                              country = selectedCountry;
                            });
                          },
                        );
                      },
                      child: Text(
                        country == null ? 'Pick Country' : country!.name,
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (country != null) Text('+${country!.phoneCode}'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !loading,
                            decoration: const InputDecoration(
                              hintText: 'phone number',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (country == null) {
                                return 'Please select a country first';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (loading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: 90,
                        child: CustomButton(
                          onPressed: loading ? (){} : () {
                            if (_formKey.currentState!.validate()) {
                              final fullPhoneNumber =
                                  '+${country!.phoneCode}${phoneController.text.trim()}';
                              context.read<PhoneAuthBloc>().add(
                                VerifyPhoneNumberEvent(
                                    phoneNumber: fullPhoneNumber),
                              );
                            }
                          },
                          text: 'Next',
                        ),
                      ),
                    SizedBox(height: size.height * .04),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}