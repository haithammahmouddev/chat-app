part of 'select_contact_cubit.dart';

@immutable
sealed class SelectContactState {}

final class SelectContactInitial extends SelectContactState {}

final class SelectContactLoading extends SelectContactState {}

final class SelectContactLoaded extends SelectContactState {
  final List<Contact> contacts;

  SelectContactLoaded(this.contacts);
}

final class SelectContactError extends SelectContactState {
  final String message;

  SelectContactError(this.message);
}