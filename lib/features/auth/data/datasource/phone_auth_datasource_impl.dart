import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';
import 'package:whats_app/core/network/firebase/firebase_service.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/phone_verification_phone.dart';
import '../models/user_model.dart';
import 'phone_auth_datasource.dart';

class PhoneAuthDatasourceImpl implements PhoneAuthDatasource {
  final FirebaseClient _authClient;
  final DatabaseService databaseService;
  PhoneAuthDatasourceImpl(this._authClient, {required this.databaseService});

  @override
  Future<PhoneVerificationModel> verifyPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      final completer = Completer<PhoneVerificationModel>();

      await _authClient.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {},

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(_mapPhoneVerificationError(e.code)),
            );
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(
                PhoneVerificationModel(
              verificationId: verificationId,
              resendToken: resendToken,));
          }
        },

        codeAutoRetrievalTimeout: (_) {},
      );

      return completer.future;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapPhoneVerificationError(e.code));
    } catch (_) {
      throw ServerException(
        'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      );
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final userCredential = await _authClient.verifyOtp(verificationId: verificationId, smsCode: smsCode);

      final user = userCredential.user;

      if (user == null) {
        throw AuthException('فشل تسجيل الدخول');
      }

      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapOtpError(e.code));
    } catch (_) {
      throw ServerException(
        'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      );
    }
  }
  @override
  Future<PhoneVerificationModel> resendOtp({
    required String phoneNumber,
      int? resendToken,
  }) async {
    try {
      final completer = Completer<PhoneVerificationModel>();

      await _authClient.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {},

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(_mapPhoneVerificationError(e.code)),
            );
          }
        },

        codeSent: (String verificationId, int? newResendToken) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationModel(
                verificationId: verificationId,
                resendToken: newResendToken,
              ),
            );
          }
        },

        codeAutoRetrievalTimeout: (_) {},
      );

      return completer.future;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapPhoneVerificationError(e.code));
    } catch (_) {
      throw ServerException(
        'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      );
    }
  }
  String _mapPhoneVerificationError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';

      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات، حاول لاحقاً';

      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح لإرسال الرسائل';

      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';

      case 'captcha-check-failed':
        return 'فشل التحقق الأمني';

      case 'app-not-authorized':
        return 'التطبيق غير مصرح';

      case 'operation-not-allowed':
        return 'Phone Authentication غير مفعل';

      default:
        return 'تعذر إرسال رمز التحقق';
    }
  }

  String _mapOtpError(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';

      case 'session-expired':
        return 'انتهت صلاحية رمز التحقق';

      case 'invalid-verification-id':
        return 'بيانات التحقق غير صالحة';

      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';

      default:
        return 'فشل التحقق من OTP';
    }
  }

}