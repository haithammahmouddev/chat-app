


import '../../../group/data/models/droup_model.dart';
import 'chat_contact_model.dart';

class ChatListItemModel {
  final String id;
  final String name;
  final String? image;
  final String lastMessage;
  final DateTime timeSent;
  final bool isGroup;

  ChatListItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.lastMessage,
    required this.timeSent,
    required this.isGroup,
  });

  factory ChatListItemModel.fromChatContact(ChatContactModel contact) {
    return ChatListItemModel(
      id: contact.contactId,
      name: contact.name,
      image: contact.image,
      lastMessage: contact.lastMessage,
      timeSent: contact.timeSent,
      isGroup: false,
    );
  }

  factory ChatListItemModel.fromGroup(GroupModel group) {
    return ChatListItemModel(
      id: group.groupId,
      name: group.name,
      image: group.groupPic,
      lastMessage: group.lastMessage,
      timeSent: group.timeSent,
      isGroup: true,
    );
  }
}