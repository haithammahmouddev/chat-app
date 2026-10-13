import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/models/contact/contact.dart';
import '../../group_cubit/group_cubit.dart';

class SelectContactsGroup extends StatefulWidget {
  const SelectContactsGroup({super.key, required this.onSelectionChanged});

  final ValueChanged<List<Contact>> onSelectionChanged;

  @override
  State<SelectContactsGroup> createState() => _SelectContactsGroupState();
}

class _SelectContactsGroupState extends State<SelectContactsGroup> {

  final List<Contact> selectedContacts = [];

  void selectContact(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
    widget.onSelectionChanged(selectedContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<GroupCubit, GroupState>(
        buildWhen: (previous, current) =>
        current is SelectContactLoading ||
            current is SelectContactLoaded ||
            current is SelectContactFailure,
        builder: (context, state) {
          if (state is SelectContactLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is SelectContactFailure) {
            return Center(
              child: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          if (state is SelectContactLoaded) {
            if (state.contacts.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد معارف مسجلين في التطبيق',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final contact = state.contacts[index];
                final isSelected = selectedContacts.contains(contact);

                return InkWell(
                  onTap: () => selectContact(contact),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        contact.displayName ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.done, color: Colors.teal)
                          : null,
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}