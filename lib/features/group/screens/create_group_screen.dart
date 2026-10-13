import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/models/contact/contact.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/features/group/screens/widgets/select_contacts_group.dart';
import '../../../../colors.dart';
import '../../../../core/di/injection_container.dart';
import '../group_cubit/group_cubit.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;
  List<Contact> selectedContacts = [];

  void selectImage() async {
    image = await _showMediaSourceDialog();
    setState(() {});
  }

  void onSelectionChanged(List<Contact> contacts) {
    setState(() {
      selectedContacts = contacts;
    });
  }

  void createGroup(BuildContext context) {
    if (groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اكتب اسم الجروب')),
      );
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك اختار صورة للجروب')),
      );
      return;
    }

    if (selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختار عضو واحد على الأقل')),
      );
      return;
    }

    context.read<GroupCubit>().createGroup(
      name: groupNameController.text.trim(),
      profilePic: image!,
      selectedContacts: selectedContacts,
    );
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GroupCubit>()..getContacts(),
      child: Builder(
        builder: (innerContext) {
          return BlocListener<GroupCubit, GroupState>(
            listenWhen: (previous, current) =>
            current is GroupCreateSuccess || current is GroupCreateFailure,
            listener: (context, state) {
              if (state is GroupCreateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage)),
                );
              }
              if (state is GroupCreateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إنشاء الجروب بنجاح')),
                );
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Create Group'),
              ),
              body: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        image == null
                            ? const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                          ),
                          radius: 64,
                        )
                            : CircleAvatar(
                          backgroundImage: FileImage(image!),
                          radius: 64,
                        ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: groupNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Group Name',
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        'Select Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SelectContactsGroup(onSelectionChanged: onSelectionChanged),
                  ],
                ),
              ),
              floatingActionButton: BlocBuilder<GroupCubit, GroupState>(
                buildWhen: (previous, current) =>
                current is GroupCreateLoading ||
                    current is GroupCreateSuccess ||
                    current is GroupCreateFailure,
                builder: (context, state) {
                  final isCreating = state is GroupCreateLoading;
                  return FloatingActionButton(
                    onPressed: isCreating ? null : () => createGroup(context),
                    backgroundColor: tabColor,
                    child: isCreating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.done, color: Colors.white),
                  );
                },
              ),
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