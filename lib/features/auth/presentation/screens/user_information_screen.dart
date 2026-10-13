import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/colors.dart';

import '../../../../core/di/injection_container.dart';
import '../controllers/profile_controller/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadUser(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.redAccent,
                ),
              );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Center(
                    child: GestureDetector(
                      onTap: state.isLoading
                          ? null
                          : () => _showImageSourceDialog(context, state),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(state.image!)
                          ),

                           if (state.isLoading)
                            const Positioned.fill(
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.black45,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          if (!state.isLoading)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: tabColor,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ProfileListTile(
                    title: 'Name',
                    subTitle: state.name ?? '',
                    leading: Icons.person,
                    trailing: Icons.edit,
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: backgroundColor,
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const EditNameBottomSheet(),
                        ),
                      );
                    },
                  ),

                  const Divider(
                    color: dividerColor,
                    indent: 70,
                  ),

                  ProfileListTile(
                    title: 'About',
                    subTitle: state.about ?? '',
                    leading: Icons.info_outline,
                    trailing: Icons.edit,
                    onTap: () {
                      final cubit = context.read<ProfileCubit>();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: backgroundColor,
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const EditAboutBottomSheet(),
                        ),
                      );
                    },
                  ),

                  const Divider(
                    color: dividerColor,
                    indent: 70,
                  ),

                  ProfileListTile(
                    title: 'Phone',
                    subTitle: state.phone ?? '',
                    leading: Icons.phone,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, ProfileState state) {
    final cubit = context.read<ProfileCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Choose Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.pickImage(ImageSource.camera);
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
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.pickImage(ImageSource.gallery);
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

class ProfileListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData leading;
  final IconData? trailing;
  final VoidCallback? onTap;

  const ProfileListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        leading,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: trailing != null
          ? Icon(
        trailing,
        color: tabColor,
      )
          : null,
    );
  }
}

class EditNameBottomSheet extends StatefulWidget {
  const EditNameBottomSheet({super.key});

  @override
  State<EditNameBottomSheet> createState() => _EditNameBottomSheetState();
}

class _EditNameBottomSheetState extends State<EditNameBottomSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    _controller = TextEditingController(
      text: cubit.state.name ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() async {
    final cubit = context.read<ProfileCubit>();

    if (_controller.text.trim().isEmpty) {
      setState(() => _errorText = 'Name cannot be empty');
      return;
    }

    await cubit.updateName(_controller.text);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 25,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tabColor,
              ),
              onPressed: _onSave,
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}

class EditAboutBottomSheet extends StatefulWidget {
  const EditAboutBottomSheet({super.key});

  @override
  State<EditAboutBottomSheet> createState() => _EditAboutBottomSheetState();
}

class _EditAboutBottomSheetState extends State<EditAboutBottomSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<ProfileCubit>();

    _controller = TextEditingController(
      text: cubit.state.about ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() async {
    final cubit = context.read<ProfileCubit>();

    if (_controller.text.trim().isEmpty) {
      setState(() => _errorText = 'About cannot be empty');
      return;
    }

    await cubit.updateAbout(_controller.text);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            maxLength: 100,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            decoration: InputDecoration(
              hintText: 'About',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tabColor,
              ),
              onPressed: _onSave,
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}