class HardcodedUser {
  final int id;
  final String username;
  final String password;
  final String role;

  HardcodedUser(
      {required this.id,
      required this.username,
      required this.password,
      required this.role});
}

class HardcodedUsers {
  static final _users = <HardcodedUser>[
    HardcodedUser(id: 1, username: 'emp1', password: 'emp1', role: 'employee'),
    HardcodedUser(id: 2, username: 'mgr1', password: 'mgr1', role: 'manager'),
    HardcodedUser(id: 3, username: 'fin1', password: 'fin1', role: 'finance'),
  ];

  static HardcodedUser? authenticate(
      String username, String password, String role) {
    try {
      return _users.firstWhere((u) =>
          u.username == username && u.password == password && u.role == role);
    } catch (_) {
      return null;
    }
  }
}
