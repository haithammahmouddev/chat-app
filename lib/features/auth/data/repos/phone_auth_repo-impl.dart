import 'package:dartz/dartz.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';
import 'package:whats_app/core/services/preference_manager.dart';
import 'package:whats_app/features/auth/data/models/user_model.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/save_user_by_hive.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/phone_auth_repo.dart';
import '../datasource/phone_auth_datasource.dart';
import '../models/phone_verification_phone.dart';

class PhoneAuthRepositoryImpl implements PhoneAuthRepository {
  final PhoneAuthDatasource datasource;
  final DatabaseService databaseService;

  PhoneAuthRepositoryImpl(this.datasource, {required this.databaseService});

  @override
  Future<Either<Failure, PhoneVerificationModel>> verifyPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      final result = await datasource.verifyPhoneNumber(
        phoneNumber: phoneNumber,
      );

      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = await datasource.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userModel = UserModel.fromUserEntity(user);
      await databaseService.setData(path: 'users', docId: userModel.uid, data: userModel.toJson());
      await UserRepository().saveUser(userModel);
      await PreferencesManager().setBool('is_login', true);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PhoneVerificationModel>> resendOtp({
    required String phoneNumber,
      int? resendToken,
  }) async {
    try {
      final result = await datasource.resendOtp(
        phoneNumber: phoneNumber,
        resendToken: resendToken,
      );

      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, UserEntity>> getStreamData({required String uId}) async* {
    try {
      await for (var response in databaseService.getUserDataStream(path: 'users', docId: uId)) {
        final orders = UserModel.fromJson(response).toEntity();
        yield Right(orders);
      }
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }
}