enum UserRole {
  customer,
  driver;

  @override
  String toString() {
    return name;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.customer,
    );
  }
} 