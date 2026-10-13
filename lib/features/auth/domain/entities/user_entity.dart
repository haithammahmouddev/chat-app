class UserEntity {
  final String uid;
  final String name;
  final String phoneNumber;
  final String? image;
  final String about;
  final bool isOnline;
  final List<String> groupId;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.image,
    required this.about,
    required this.isOnline,
    required this.groupId,
  });
}