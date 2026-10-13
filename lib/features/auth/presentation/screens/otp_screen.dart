import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:whats_app/features/chat/screens/chat_home_screen.dart';
import '../../../../colors.dart';
import '../controllers/phone_auth_controller/phone_auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController otpController;
  late final FocusNode focusNode;

  late String verificationId;
  int? resendToken;

  int seconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    verificationId = widget.verificationId;
    resendToken = widget.resendToken;

    otpController = TextEditingController();
    focusNode = FocusNode();

    startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void startTimer() {
    timer?.cancel();
    seconds = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tabColor, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Verify phone number",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
        listener: (context, state) {
          if (state is OtpVerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is PhoneAuthSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ChatHomeScreen()),
              (_) => false,
            );
          }

          if (state is OtpResendFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is OtpResendSuccess) {
            verificationId = state.verificationId;
            resendToken = state.resendToken;
            otpController.clear();
            startTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم إرسال رمز جديد عبر SMS")),
            );
          }
        },
        builder: (context, state) {
          final verifyLoading = state is OtpVerifying;
          final resendLoading = state is OtpResending;
          final hasVerifyError = state is OtpVerificationFailure;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    CircleAvatar(
                      radius: 45,
                      backgroundColor: tabColor.withValues(alpha: .12),
                      child: const Icon(
                        Icons.sms_outlined,
                        color: tabColor,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Verification Code",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Enter the 6-digit code sent via SMS to\n${widget.phoneNumber}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        length: 6,
                        controller: otpController,
                        focusNode: focusNode,
                        autofocus: true,
                        enabled: !verifyLoading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: defaultPinTheme,
                        errorPinTheme: errorPinTheme,
                        forceErrorState: hasVerifyError,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tabColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: tabColor.withValues(alpha: .5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: verifyLoading
                            ? null
                            : () {
                                if (otpController.text.length != 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Enter valid OTP"),
                                    ),
                                  );
                                  return;
                                }

                                context.read<PhoneAuthBloc>().add(
                                  VerifyOtpEvent(
                                    verificationId: verificationId,
                                    smsCode: otpController.text.trim(),
                                  ),
                                );
                              },
                        child: verifyLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Verify",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      seconds == 0
                          ? "Didn't receive the code?"
                          : "Resend SMS in 00:${seconds.toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    TextButton(
                      onPressed: (seconds == 0 && !resendLoading)
                          ? () {
                              context.read<PhoneAuthBloc>().add(
                                ResendOtpEvent(
                                  phoneNumber: widget.phoneNumber,
                                  resendToken: resendToken,
                                ),
                              );
                            }
                          : null,
                      child: resendLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              "Resend SMS",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: seconds == 0 ? tabColor : Colors.grey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
