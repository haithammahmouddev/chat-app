import 'package:equatable/equatable.dart';

abstract class SendMessageState extends Equatable {
  const SendMessageState();

  @override
  List<Object?> get props => [];
}

class SendMessageInitial extends SendMessageState {
  const SendMessageInitial();
}

class SendMessageLoading extends SendMessageState {
  const SendMessageLoading();
}

class SendMessageSuccess extends SendMessageState {
  const SendMessageSuccess();
}

class SendMessageError extends SendMessageState {
  final String message;

  const SendMessageError(this.message);

  @override
  List<Object?> get props => [message];
}