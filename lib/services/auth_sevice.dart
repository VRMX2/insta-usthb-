import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Exception class for authentication-related errors
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => message;
}

/// Result class for authentication operations
class AuthResult {
  final User? user;
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  const AuthResult({
    this.user,
    required this.success,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthResult.success(User user) => AuthResult(
    user: user,
    success: true,
  );

  factory AuthResult.failure(String message, [String? code]) => AuthResult(
    success: false,
    errorMessage: message,
    errorCode: code,
  );
}

/// User data model for Firestore document
class UserData {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String studentId;
  final String academicYear;
  final String specialty;
  final String faculty;
  final String university;
  final String? profileImageUrl;
  final String bio;
  final bool isVerified;
  final bool isActive;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserData({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.studentId,
    required this.academicYear,
    required this.specialty,
    required this.faculty,
    required this.university,
    this.profileImageUrl,
    this.bio = '',
    this.isVerified = false,
    this.isActive = true,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert UserData to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'studentId': studentId,
      'academicYear': academicYear,
      'specialty': specialty,
      'faculty': faculty,
      'university': university,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isVerified': isVerified,
      'isActive': isActive,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Create UserData from Firestore document
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      displayName: map['displayName'] ?? '',
      studentId: map['studentId'] ?? '',
      academicYear: map['academicYear'] ?? '',
      specialty: map['specialty'] ?? '',
      faculty: map['faculty'] ?? '',
      university: map['university'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      followerCount: map['followerCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postCount: map['postCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Registration data model
class RegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String studentId;
  final String academicYear;
  final String specialty;

  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.studentId,
    required this.academicYear,
    required this.specialty,
  });
}

/// Comprehensive Authentication Service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constants
  static const String usersCollection = 'users';
  static const String defaultFaculty = 'Faculté d\'Informatique - USTHB';
  static const String defaultUniversity = 'USTHB';

  // Academic year options for Computer Science
  static const List<String> academicYears = [
    'L1', // Licence 1
    'L2', // Licence 2
    'L3', // Licence 3
    'M1', // Master 1
    'M2', // Master 2
  ];

  // Specialty options (Computer Science specific)
  static const List<String> specialties = [
    'Informatique - Licence',
    'Génie Logiciel - Master',
    'Intelligence Artificielle - Master',
    'Réseaux et Systèmes Distribués - Master',
    'Systèmes d\'Information - Master',
    'Sécurité Informatique - Master',
    'Informatique Théorique - Master',
  ];

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Register new user with email and password
  Future<AuthResult> registerWithEmailAndPassword(RegistrationData data) async {
    try {
      // Validate registration data
      _validateRegistrationData(data);

      // Check if student ID is already taken
      final isStudentIdExists = await isStudentIdTaken(data.studentId);
      if (isStudentIdExists) {
        return AuthResult.failure('Ce numéro d\'étudiant est déjà utilisé');
      }

      // Check if email is already in use
      final isEmailExists = await isEmailTaken(data.email);
      if (isEmailExists) {
        return AuthResult.failure('Cette adresse email est déjà utilisée');
      }

      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim(),
        password: data.password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Échec de la création du compte utilisateur');
      }

      final user = userCredential.user!;

      try {
        // Update user display name
        await user.updateDisplayName('${data.firstName.trim()} ${data.lastName.trim()}');

        // Create user document in Firestore
        final userData = UserData(
          uid: user.uid,
          email: user.email!,
          firstName: data.firstName.trim(),
          lastName: data.lastName.trim(),
          displayName: '${data.firstName.trim()} ${data.lastName.trim()}',
          studentId: data.studentId.trim(),
          academicYear: data.academicYear,
          specialty: data.specialty,
          faculty: defaultFaculty,
          university: defaultUniversity,
        );

        await _createUserDocument(userData);

        // Send email verification
        await _sendEmailVerification(user);

        return AuthResult.success(user);

      } catch (e) {
        // If Firestore operations fail, delete the created user account
        try {
          await user.delete();
        } catch (deleteError) {
          debugPrint('Error deleting user after failed registration: $deleteError');
        }
        rethrow;
      }

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code), e.code);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message, e.code);
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResult.failure('Erreur lors de la création du compte: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        return AuthResult.failure('Email et mot de passe requis');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Format d\'email invalide');
      }

      // Attempt to sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Échec de la connexion');
      }

      return AuthResult.success(userCredential.user!);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure('Une erreur inattendue s\'est produite lors de la connexion');
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      // Validate email
      if (email.trim().isEmpty) {
        return AuthResult.failure('Adresse email requise');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Format d\'email invalide');
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email.trim());

      return const AuthResult(success: true);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('Une erreur inattendue s\'est produite lors de l\'envoi de l\'email');
    }
  }

  /// Send email verification to current user
  Future<AuthResult> sendEmailVerificationToCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Aucun utilisateur connecté');
      }

      if (user.emailVerified) {
        return AuthResult.failure('Email déjà vérifié');
      }

      await _sendEmailVerification(user);
      return const AuthResult(success: true);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('Email verification error: $e');
      return AuthResult.failure('Erreur lors de l\'envoi de l\'email de vérification');
    }
  }

  /// Reload current user to get updated email verification status
  Future<void> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Sign out current user
  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      return const AuthResult(success: true);
    } catch (e) {
      debugPrint('Sign out error: $e');
      return AuthResult.failure('Erreur lors de la déconnexion');
    }
  }

  /// Delete current user account
  Future<AuthResult> deleteCurrentUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Aucun utilisateur connecté');
      }

      // Delete user document from Firestore first
      await _deleteUserDocument(user.uid);

      // Delete user account
      await user.delete();

      return const AuthResult(success: true);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code), e.code);
    } catch (e) {
      debugPrint('Delete account error: $e');
      return AuthResult.failure('Erreur lors de la suppression du compte');
    }
  }

  // ============================================================================
  // FIRESTORE USER DOCUMENT METHODS
  // ============================================================================

  /// Get user data from Firestore
  Future<UserData?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserData.fromMap(doc.data()!);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  /// Get current user data from Firestore
  Future<UserData?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await getUserData(user.uid);
  }

  /// Get user data stream from Firestore
  Stream<UserData?> getUserDataStream(String uid) {
    return _firestore
        .collection(usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserData.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Update user data in Firestore
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Add updatedAt timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(usersCollection).doc(uid).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating user data: $e');
      return false;
    }
  }

  /// Update current user data
  Future<bool> updateCurrentUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    return await updateUserData(user.uid, data);
  }

  /// Check if student ID is already in use
  Future<bool> isStudentIdTaken(String studentId) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('studentId', isEqualTo: studentId.trim())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking student ID: $e');
      return false;
    }
  }

  /// Check if email is already in use
  Future<bool> isEmailTaken(String email) async {
    try {
      final query = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email: $e');
      return false;
    }
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Validate registration data
  void _validateRegistrationData(RegistrationData data) {
    if (data.firstName.trim().isEmpty) {
      throw const AuthException(
        message: 'Prénom requis',
        code: 'missing-first-name',
      );
    }

    if (data.firstName.trim().length < 2) {
      throw const AuthException(
        message: 'Prénom trop court (minimum 2 caractères)',
        code: 'invalid-first-name',
      );
    }

    if (data.lastName.trim().isEmpty) {
      throw const AuthException(
        message: 'Nom requis',
        code: 'missing-last-name',
      );
    }

    if (data.lastName.trim().length < 2) {
      throw const AuthException(
        message: 'Nom trop court (minimum 2 caractères)',
        code: 'invalid-last-name',
      );
    }

    if (!_isValidEmail(data.email)) {
      throw const AuthException(
        message: 'Format d\'email invalide',
        code: 'invalid-email',
      );
    }

    if (data.password.length < 6) {
      throw const AuthException(
        message: 'Mot de passe trop court (minimum 6 caractères)',
        code: 'weak-password',
      );
    }

    if (!_isValidStudentId(data.studentId)) {
      throw const AuthException(
        message: 'Format du numéro d\'étudiant invalide (12 chiffres requis)',
        code: 'invalid-student-id',
      );
    }

    if (!academicYears.contains(data.academicYear)) {
      throw const AuthException(
        message: 'Année académique invalide',
        code: 'invalid-academic-year',
      );
    }

    if (!specialties.contains(data.specialty)) {
      throw const AuthException(
        message: 'Spécialité invalide',
        code: 'invalid-specialty',
      );
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());
  }

  /// Validate USTHB student ID format
  bool _isValidStudentId(String studentId) {
    return RegExp(r'^\d{12}$').hasMatch(studentId.trim());
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Create user document in Firestore
  Future<void> _createUserDocument(UserData userData) async {
    try {
      // Create a simplified map without complex objects
      final userMap = {
        'uid': userData.uid,
        'email': userData.email,
        'firstName': userData.firstName,
        'lastName': userData.lastName,
        'displayName': userData.displayName,
        'studentId': userData.studentId,
        'academicYear': userData.academicYear,
        'specialty': userData.specialty,
        'faculty': userData.faculty,
        'university': userData.university,
        'profileImageUrl': userData.profileImageUrl,
        'bio': userData.bio,
        'isVerified': userData.isVerified,
        'isActive': userData.isActive,
        'followerCount': userData.followerCount,
        'followingCount': userData.followingCount,
        'postCount': userData.postCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollection)
          .doc(userData.uid)
          .set(userMap, SetOptions(merge: true));

      debugPrint('User document created successfully for UID: ${userData.uid}');
    } catch (e) {
      debugPrint('Error creating user document: $e');
      throw AuthException(
        message: 'Erreur lors de la création du profil utilisateur: ${e.toString()}',
        code: 'firestore-error',
      );
    }
  }

  /// Delete user document from Firestore
  Future<void> _deleteUserDocument(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
    } catch (e) {
      debugPrint('Error deleting user document: $e');
      // Don't throw here as we still want to delete the auth account
    }
  }

  /// Send email verification
  Future<void> _sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      // Don't throw as this is not critical for registration
    }
  }

  /// Get localized error message for Firebase Auth errors
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'operation-not-allowed':
        return 'L\'inscription par email n\'est pas autorisée.';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'invalid-credential':
        return 'Identifiants invalides. Vérifiez votre email et mot de passe.';
      case 'missing-email':
        return 'Adresse email manquante.';
      case 'network-request-failed':
        return 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
      case 'requires-recent-login':
        return 'Cette opération nécessite une reconnexion récente.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }
}