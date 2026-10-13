import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/chat_list_item_model.dart';

abstract class ChatContactsState extends Equatable {
  const ChatContactsState();

  @override
  List<Object?> get props => [];
}

class ChatContactsInitial extends ChatContactsState {
  const ChatContactsInitial();
}

class ChatContactsLoading extends ChatContactsState {
  const ChatContactsLoading();
}

class ChatContactsLoaded extends ChatContactsState {
  final List<ChatListItemModel> contacts;

  const ChatContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ChatContactsError extends ChatContactsState {
  final String message;

  const ChatContactsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecieverUserLoaded extends ChatContactsState {
  final UserModel user;

  const RecieverUserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class RecieverUserFailure extends ChatContactsState {
  final String message;

  const RecieverUserFailure({required this.message});

  @override
  List<Object?> get props => [message];
}