import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../group/data/models/droup_model.dart';
import '../../../group/data/repos/group_repository.dart';
import '../../data/models/chat_contact_model.dart';
import '../../data/models/chat_list_item_model.dart';
import '../../data/repos/chat_repo.dart';
import 'chat_contacts_state.dart';

class ChatContactsCubit extends Cubit<ChatContactsState> {
  final ChatRepo chatRepo;
  final GroupRepository groupRepository;

  ChatContactsCubit({
    required this.chatRepo,
    required this.groupRepository,
  }) : super(const ChatContactsInitial());

  StreamSubscription? _chatsSubscription;
  StreamSubscription? _groupsSubscription;

  List<ChatListItemModel> _latestChats = [];
  List<ChatListItemModel> _latestGroups = [];

  void getChatContacts() {
    emit(const ChatContactsLoading());

    _chatsSubscription = chatRepo.getChatContactsStream().listen((result) {
      result.fold(
            (failure) => emit(ChatContactsError(failure.message)),
            (List<ChatContactModel> contacts) {
          _latestChats =
              contacts.map((c) => ChatListItemModel.fromChatContact(c)).toList();
          _emitMerged();
        },
      );
    });

    _groupsSubscription = groupRepository.getUserGroupsStream().listen((result) {
      result.fold(
            (failure) => emit(ChatContactsError(failure.message)),
            (List<GroupModel> groups) {
          _latestGroups = groups.map((g) => ChatListItemModel.fromGroup(g)).toList();
          _emitMerged();
        },
      );
    });
  }

  void _emitMerged() {
    final merged = [..._latestChats, ..._latestGroups];
    merged.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    emit(ChatContactsLoaded(merged));
  }

  void updateUserStatus(bool isOnline) async {
    await chatRepo.updateUserStatus(isOnline);
  }

  @override
  Future<void> close() async {
    await _chatsSubscription?.cancel();
    await _groupsSubscription?.cancel();
    return super.close();
  }
}