import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.avatarUrl,
    this.totalRevenue = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? avatarUrl;
  final double totalRevenue;

  @override
  List<Object?> get props => [id];
}
