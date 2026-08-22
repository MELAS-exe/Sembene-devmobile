import 'package:tera/features/profile/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.avatarUrl,
    this.totalRevenue = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        bio: json['bio'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? avatarUrl;
  final double totalRevenue;

  UserProfile toEntity() => UserProfile(
        id: id,
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        avatarUrl: avatarUrl,
        totalRevenue: totalRevenue,
      );
}
