import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser{
  final bool isEmailVerified;
  AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user)=> AuthUser(isEmailVerified: user.emailVerified);
}
