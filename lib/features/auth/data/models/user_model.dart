import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    int? id,
    required String name,
    required String role,
    int? managerId,
    String? email,
    String? phone,
  }) : super(
            id: id,
            name: name,
            role: role,
            managerId: managerId,
            email: email,
            phone: phone);

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: map['role'] as String,
      managerId: map['manager_id'] as int?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'manager_id': managerId,
      'email': email,
      'phone': phone,
    };
  }
}
