import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Either<String, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'An error occurred during sign in');
    }
  }

  Future<Either<String, User>> registerWithEmailAndPassword(
    String email,
    String password, {
    UserRole role = UserRole.customer,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user role in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'An error occurred during registration');
    }
  }

  Future<Either<String, User>> signInWithGoogle({
    UserRole role = UserRole.customer,
  }) async {
    try {
      // Initialize GoogleSignIn with proper scopes
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return const Left('Google sign in aborted');
      }

      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        
        // Check if this is a new user, and if so, save their role
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'role': role.toString(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        return Right(userCredential.user!);
      } catch (authError) {
        // More detailed error for authentication failures
        return Left('Authentication failed: ${authError.toString()}');
      }
    } catch (e) {
      // Log the detailed error
      print('Google Sign-In Error: $e');
      if (e.toString().contains('network_error')) {
        return const Left('Network error. Check your internet connection.');
      } else if (e.toString().contains('canceled')) {
        return const Left('Sign in was canceled.');
      } else if (e.toString().contains('sign_in_failed')) {
        return const Left('Sign in failed. Please check your Firebase configuration and try again.');
      }
      return Left('Google sign in error: ${e.toString()}');
    }
  }

  Future<Either<String, void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'An error occurred during password reset');
    }
  }

  Future<Either<String, UserRole>> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User is not logged in');
      }
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return const Right(UserRole.customer); // Default role
      }
      
      final roleString = doc.data()?['role'] as String?;
      return Right(UserRole.fromString(roleString ?? 'customer'));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateUserRole(UserRole role) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User is not logged in');
      }
      
      await _firestore.collection('users').doc(user.uid).update({
        'role': role.toString(),
      });
      
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Gets the current logged in user
  User? get currentUser => _auth.currentUser;
} 