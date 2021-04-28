import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthEvent {}

class AuthSignedIn extends AuthEvent {}

class AuthAnonymous extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}
