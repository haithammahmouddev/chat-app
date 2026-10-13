import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/features/chat/screens/chat_room_screen.dart';
import '../../../../../colors.dart';
import '../../controllers/chat_contacts_cubit/chat_contacts_cubit.dart';
import '../../controllers/chat_contacts_cubit/chat_contacts_state.dart';
import '../../data/models/chat_list_item_model.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _openChat(BuildContext context, ChatListItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          uid: item.id,
          name: item.name,
          isGroupChat: item.isGroup,
          profilePic: item.image ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: BlocBuilder<ChatContactsCubit, ChatContactsState>(
        builder: (context, state) {
          if (state is ChatContactsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatContactsError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is ChatContactsLoaded) {
            final items = state.contacts;

            if (items.isEmpty) {
              return const Center(
                child: Text("لا توجد محادثات بعد"),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () => _openChat(context, item),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  item.image ?? '',
                                ),
                              ),
                              if (item.isGroup)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: appBarColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.group,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          trailing: Text(
                            _formatTime(item.timeSent),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (index != items.length - 1)
                      const Divider(
                        color: dividerColor,
                        indent: 85,
                      ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}