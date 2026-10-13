import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/colors.dart';
import '../status_cubit/status_cubit.dart';

class ConfirmStatusScreen extends StatelessWidget {
  const ConfirmStatusScreen({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StatusCubit, StatusState>(
      listenWhen: (previous, current) =>
      previous.uploadStatus != current.uploadStatus,
      listener: (context, state) {
        if (state.uploadStatus == StatusUploadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.uploadErrorMessage ?? 'حصل خطأ أثناء الرفع')),
          );
          context.read<StatusCubit>().resetUploadStatus();
        }

        if (state.uploadStatus == StatusUploadStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفع الحالة بنجاح')),
          );
          context.read<StatusCubit>().resetUploadStatus();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
        floatingActionButton: BlocBuilder<StatusCubit, StatusState>(
          buildWhen: (previous, current) =>
          previous.uploadStatus != current.uploadStatus,
          builder: (context, state) {
            final isUploading = state.uploadStatus == StatusUploadStatus.loading;
            return FloatingActionButton(
              onPressed: isUploading
                  ? null
                  : () => context.read<StatusCubit>().addStatus(file: file),
              backgroundColor: tabColor,
              child: isUploading
                  ? const CupertinoActivityIndicator()
                  : const Icon(Icons.done, color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}