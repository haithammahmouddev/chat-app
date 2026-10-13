import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whats_app/features/select_contact/repos/select_contact_repository.dart';

import '../../../core/network/firebase/database_service_impl.dart';
import '../controllere/select_contact_controller/select_contact_cubit.dart';

class SelectContactScreen extends StatelessWidget {
  const SelectContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SelectContactCubit(SelectContactRepository(firestore:
          DatabaseServiceImpl(firestore: FirebaseFirestore.instance)))..getContacts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Contact"),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: BlocBuilder<SelectContactCubit, SelectContactState>(
          builder: (context, state) {
            final Controller = context.read<SelectContactCubit>();
            if (state is SelectContactLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is SelectContactLoaded) {
              return ListView.builder(
                itemCount: state.contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = state.contacts[index];

                  return InkWell(
                    onTap: () {
                      Controller.selectContact(state.contacts[index], context);
                    },
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(contact.displayName ?? ''),
                      subtitle: Text(
                        contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : '',
                      ),
                    ),
                  );
                },
              );
            }

            if (state is SelectContactError) {
              return Center(
                child: Text(state.message),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}