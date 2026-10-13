import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';
import 'package:whats_app/features/auth/data/models/user_model.dart';
import 'package:whats_app/features/chat/screens/chat_room_screen.dart';

class SelectContactRepository {
  final DatabaseService firestore ;
  SelectContactRepository({required this.firestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    try {
       final status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
       if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
         contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.phone, ContactProperty.name},
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return contacts;
  }

  Future<void> selectContact(
      Contact selectedContact,
      BuildContext context,
      ) async {
    try {
      final users = await firestore.getAllData(path: 'users');

      bool isFound = false;

      if (selectedContact.phones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact has no phone number'),
          ),
        );
        return;
      }

      String selectedPhone = _normalizePhone(
        selectedContact.phones.first.number,
      );

      for (final document in users.docs) {
        final user = UserModel.fromJson(document.data());

        String firestorePhone = _normalizePhone(user.phoneNumber);

        if (selectedPhone == firestorePhone) {
          isFound = true;

          debugPrint("User Found : ${user.name}");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                uid: user.uid,
                name: user.name, isGroupChat: false, profilePic: user.image ?? '',
              ),
            ),
          );

          break;
        }
      }

      if (!isFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This number is not registered on WhatsApp",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String _normalizePhone(String phone) {
    return phone
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');
  }



}
