import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/features/status/screens/status_screen.dart';
import '../../../../colors.dart';
import '../status_cubit/status_cubit.dart';

class StatusContactsScreen extends StatefulWidget {
  const StatusContactsScreen({super.key, required this.controller});
  final StatusCubit controller;

  @override
  State<StatusContactsScreen> createState() => _StatusContactsScreenState();
}

class _StatusContactsScreenState extends State<StatusContactsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StatusCubit, StatusState>(
        buildWhen: (previous, current) =>
        previous.listStatus != current.listStatus ||
            previous.myStatus != current.myStatus ||
            previous.contactsStatus != current.contactsStatus,
        builder: (context, state) {
          if (state.listStatus == StatusListStatus.loading ||
              state.listStatus == StatusListStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.listStatus == StatusListStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'حصل خطأ أثناء تحميل الحالات',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView(
            children: [
              _buildMyStatusTile(context, state),
              const Divider(color: dividerColor, indent: 85),
              if (state.contactsStatus.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Recent updates',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                for (final statusData in state.contactsStatus)
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StatusScreen(status: statusData),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(statusData.userName),
                            subtitle: Text(statusData.formattedTime),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(statusData.profilePic),
                              radius: 30,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: dividerColor, indent: 85),
                    ],
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyStatusTile(BuildContext context, StatusState state) {
    final myStatus = state.myStatus;

    if (myStatus == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
            child: Icon(Icons.add, color: Colors.white),
          ),
          title: Text('My status'),
          subtitle: Text('Tap to add status update'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StatusScreen(status: myStatus)),
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(myStatus.profilePic),
          radius: 30,
        ),
        title: const Text('My status'),
        subtitle: Text(myStatus.formattedTime),
      ),
    );
  }
}