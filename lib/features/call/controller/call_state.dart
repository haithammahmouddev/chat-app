
part of 'call_cubit.dart';

@immutable
abstract class CallState {}

class CallInitial extends CallState {}

class CallMakeLoading extends CallState {}

class CallMakeSuccess extends CallState {
  final CallModel call;
  final bool isGroupChat;

  CallMakeSuccess({
    required this.call,
    required this.isGroupChat,
  });
}

class CallMakeFailure extends CallState {
  final String error;
  CallMakeFailure(this.error);
}

class CallEndLoading extends CallState {}

class CallEndSuccess extends CallState {}

class CallEndFailure extends CallState {
  final String error;
  CallEndFailure(this.error);
}