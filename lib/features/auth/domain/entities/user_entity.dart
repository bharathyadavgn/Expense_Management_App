class UserEntity {
  final int? id;
  final String name;
  final String role;
  final int? managerId;
  final String? email;
  final String? phone;

  UserEntity({
    this.id,
    required this.name,
    required this.role,
    this.managerId,
    this.email,
    this.phone,
  });
}
