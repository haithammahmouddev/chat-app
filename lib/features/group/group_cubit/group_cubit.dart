import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_contacts/models/contact/contact.dart';
import 'package:meta/meta.dart';
import '../data/repos/group_repository.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepository repository;

  GroupCubit({required this.repository}) : super(GroupInitial());

  Future<void> getContacts() async {
    emit(SelectContactLoading());
    try {
      final contacts = await repository.getContacts();
      emit(SelectContactLoaded(contacts: contacts));
    } catch (e) {
      emit(SelectContactFailure(e.toString()));
    }
  }

  Future<void> createGroup({
    required String name,
    required File profilePic,
    required List<Contact> selectedContacts,
  }) async {
    emit(GroupCreateLoading());
    try {
      await repository.createGroup(
        name: name,
        profilePic: profilePic,
        selectedContact: selectedContacts,
      );
      emit(GroupCreateSuccess());
    } catch (e) {
      emit(GroupCreateFailure(e.toString()));
    }
  }
}