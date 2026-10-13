import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/features/auth/presentation/screens/user_information_screen.dart';
import 'package:whats_app/features/select_contact/screens/select_contact_screen.dart';
import '../../../../colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../group/screens/create_group_screen.dart';
import '../../status/screens/confirm_status_screen.dart';
import '../../status/screens/status_contacts_screen.dart';
import '../../status/status_cubit/status_cubit.dart';
import '../controllers/chat_contacts_cubit/chat_contacts_cubit.dart';
import 'widgets/contacts_list.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
    context.read<ChatContactsCubit>().updateUserStatus(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    final chatCubit = context.read<ChatContactsCubit>();
    switch (state) {
      case AppLifecycleState.resumed:
        chatCubit.updateUserStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        chatCubit.updateUserStatus(false);
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StatusCubit>()..loadStatuses(),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: appBarColor,
              centerTitle: false,
              title: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                     if (value == 'profile') {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                    }
                   else if (value == 'create_group') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('My Profile'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'create_group',
                        child: Text('Create Group'),
                      ),
                    ];
                  },
                )

              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: tabColor,
                indicatorWeight: 4,
                labelColor: tabColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'CHATS'),
                  Tab(text: 'STATUS'),
                  Tab(text: 'CALLS'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                const ContactsList(),
                StatusContactsScreen(
                  controller: innerContext.read<StatusCubit>(),
                ),
                const Center(
                  child: Text('Calls Screen', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            floatingActionButton: _tabController.index == 2
                ? null
                : FloatingActionButton(
              backgroundColor: tabColor,
              child: Icon(
                _tabController.index == 0 ? Icons.comment : Icons.camera_alt,
                color: Colors.white,
              ),
              onPressed: () async {
                if (_tabController.index == 0) {
                  Navigator.push(
                    innerContext,
                    MaterialPageRoute(builder: (_) => const SelectContactScreen()),
                  );
                } else if (_tabController.index == 1) {
                  File? pickedImage = await _showMediaSourceDialog();
                  if (pickedImage != null && mounted) {
                    Navigator.push(
                      innerContext,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: innerContext.read<StatusCubit>(),
                          child: ConfirmStatusScreen(file: pickedImage),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint("Error picking image: ${e.toString()}");
      return null;
    }
  }

  Future<File?> _showMediaSourceDialog() {
    return showDialog<File?>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                final file = await pickImage(ImageSource.camera);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, file);
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text('Camera'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final file = await pickImage(ImageSource.gallery);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, file);
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 10),
                  Text('Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}