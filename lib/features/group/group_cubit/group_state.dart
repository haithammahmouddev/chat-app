part of 'group_cubit.dart';

@immutable
abstract class GroupState {}

class GroupInitial extends GroupState {}

class SelectContactLoading extends GroupState {}

class SelectContactLoaded extends GroupState {
  final List<Contact> contacts;
  SelectContactLoaded({required this.contacts});
}

class SelectContactFailure extends GroupState {
  final String errorMessage;
  SelectContactFailure(this.errorMessage);
}

class GroupCreateLoading extends GroupState {}

class GroupCreateSuccess extends GroupState {}

class GroupCreateFailure extends GroupState {
  final String errorMessage;
  GroupCreateFailure(this.errorMessage);
}