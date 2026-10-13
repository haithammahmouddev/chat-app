import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:meta/meta.dart';
import 'package:whats_app/features/select_contact/repos/select_contact_repository.dart';

part 'select_contact_state.dart';

class SelectContactCubit extends Cubit<SelectContactState> {
  final SelectContactRepository repository;

  SelectContactCubit(this.repository) : super(SelectContactInitial());

  Future<void> getContacts() async {
    emit(SelectContactLoading());
    try {
      final contacts = await repository.getContacts();
      if (contacts.isEmpty) {
        emit(SelectContactError("لا توجد جهات اتصال متاحة أو لم يتم منح الصلاحية"));
      } else {
        emit(SelectContactLoaded(contacts));
      }
    } catch (e) {
      emit(SelectContactError(e.toString()));
    }
  }

  void selectContact(Contact chosenContact, BuildContext context) {
    repository.selectContact(chosenContact, context);
  }

}
