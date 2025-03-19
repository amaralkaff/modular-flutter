import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<Either<String, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  Future<Either<String, User>> registerWithEmailAndPassword(
    String email,
    String password, {
    UserRole role = UserRole.customer,
  }) async {
    return _authService.registerWithEmailAndPassword(email, password, role: role);
  }

  Future<Either<String, User>> signInWithGoogle({
    UserRole role = UserRole.customer,
  }) async {
    return _authService.signInWithGoogle(role: role);
  }

  Future<Either<String, void>> signOut() async {
    return _authService.signOut();
  }

  Future<Either<String, void>> resetPassword(String email) async {
    return _authService.resetPassword(email);
  }
  
  Future<Either<String, UserRole>> getUserRole() async {
    return _authService.getUserRole();
  }
  
  Future<Either<String, void>> updateUserRole(UserRole role) async {
    return _authService.updateUserRole(role);
  }

  User? get currentUser => _authService.currentUser;
} 