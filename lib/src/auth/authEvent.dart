import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthEvent {}

class AuthUserLogin extends AuthEvent {}

class AuthAnonymousLogin extends AuthEvent {}
