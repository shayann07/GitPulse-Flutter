class UserProfile {
  final String uid;
  final String username;
  final String? avatarUrl;
  final String? email;

  const UserProfile({
    required this.uid,
    required this.username,
    this.avatarUrl,
    this.email,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      username: (data['username'] ?? '') as String,
      avatarUrl: data['avatarUrl'] as String?,
      email: data['email'] as String?,
    );
  }
}
