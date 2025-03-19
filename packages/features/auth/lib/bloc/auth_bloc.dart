import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../models/user_role.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailAndPassword(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const RegisterWithEmailAndPassword(
    this.email,
    this.password, {
    this.role = UserRole.customer,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class SignInWithGoogle extends AuthEvent {
  final UserRole role;

  const SignInWithGoogle({this.role = UserRole.customer});

  @override
  List<Object?> get props => [role];
}

class SignOut extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword(this.email);

  @override
  List<Object?> get props => [email];
}

class UpdateUserRole extends AuthEvent {
  final UserRole role;

  const UpdateUserRole(this.role);

  @override
  List<Object?> get props => [role];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final UserRole role;

  const Authenticated(this.user, this.role);

  @override
  List<Object?> get props => [user, role];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<RegisterWithEmailAndPassword>(_onRegisterWithEmailAndPassword);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOut>(_onSignOut);
    on<ResetPassword>(_onResetPassword);
    on<UpdateUserRole>(_onUpdateUserRole);

    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        final roleResult = await _authRepository.getUserRole();
        roleResult.fold(
          (error) => emit(AuthError(error)),
          (role) => emit(Authenticated(user, role)),
        );
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithEmailAndPassword(
      event.email,
      event.password,
    );
    result.fold(
      (error) => emit(AuthError(error)),
      (user) async {
        final roleResult = await _authRepository.getUserRole();
        roleResult.fold(
          (error) => emit(AuthError(error)),
          (role) => emit(Authenticated(user, role)),
        );
      },
    );
  }

  Future<void> _onRegisterWithEmailAndPassword(
    RegisterWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.registerWithEmailAndPassword(
      event.email,
      event.password,
      role: event.role,
    );
    result.fold(
      (error) => emit(AuthError(error)),
      (user) => emit(Authenticated(user, event.role)),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithGoogle(role: event.role);
    result.fold(
      (error) => emit(AuthError(error)),
      (user) async {
        final roleResult = await _authRepository.getUserRole();
        roleResult.fold(
          (error) => emit(AuthError(error)),
          (role) => emit(Authenticated(user, role)),
        );
      },
    );
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.signOut();
    result.fold(
      (error) => emit(AuthError(error)),
      (_) {
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.resetPassword(event.email);
    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.updateUserRole(event.role);
    result.fold(
      (error) => emit(AuthError(error)),
      (_) {
        final user = _authRepository.currentUser;
        if (user != null) {
          emit(Authenticated(user, event.role));
        }
      },
    );
  }
} 