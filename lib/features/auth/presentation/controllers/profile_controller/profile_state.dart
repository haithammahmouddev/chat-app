part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  final XFile? selectedImage;
  final String? image;
  final String? name;
  final String? about;
  final String? phone;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.selectedImage,
    this.image,
    this.name,
    this.about,
    this.phone,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    XFile? selectedImage,
    String? image,
    String? name,
    String? about,
    String? phone,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      selectedImage: selectedImage ?? this.selectedImage,
      image: image ?? this.image,
      name: name ?? this.name,
      about: about ?? this.about,
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    selectedImage,
    image,
    name,
    about,
    phone,
    isLoading,
    errorMessage,
  ];
}