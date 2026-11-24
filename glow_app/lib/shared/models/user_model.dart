class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int age;
  final String gender; // 'female' | 'male' | 'unspecified'
  final String theme;  // 'pink' | 'blue'
  final DateTime createdAt;
  final DateTime? consentAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.age = 25,
    this.gender = 'female',
    this.theme = 'pink',
    DateTime? createdAt,
    this.consentAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'age': age,
      'gender': gender,
      'theme': theme,
      'createdAt': createdAt.toIso8601String(),
      'consentAt': consentAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'female',
      theme: map['theme'] ?? 'pink',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      consentAt: map['consentAt'] != null
          ? DateTime.tryParse(map['consentAt'])
          : null,
    );
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    int? age,
    String? gender,
    String? theme,
    DateTime? consentAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      theme: theme ?? this.theme,
      createdAt: createdAt,
      consentAt: consentAt ?? this.consentAt,
    );
  }
}
