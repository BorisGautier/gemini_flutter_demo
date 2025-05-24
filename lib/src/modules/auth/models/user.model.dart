import 'package:equatable/equatable.dart';

/// Modèle de données pour représenter un utilisateur
class UserModel extends Equatable {
  /// Identifiant unique de l'utilisateur
  final String uid;

  /// Adresse email de l'utilisateur
  final String? email;

  /// Nom d'affichage de l'utilisateur
  final String? displayName;

  /// URL de la photo de profil
  final String? photoURL;

  /// Numéro de téléphone de l'utilisateur
  final String? phoneNumber;

  /// Statut de vérification de l'email
  final bool emailVerified;

  /// Indique si l'utilisateur est connecté de manière anonyme
  final bool isAnonymous;

  /// Date de création du compte
  final DateTime? creationTime;

  /// Date de dernière connexion
  final DateTime? lastSignInTime;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.creationTime,
    this.lastSignInTime,
  });

  /// Factory pour créer un UserModel à partir d'un Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      emailVerified: map['emailVerified'] ?? false,
      isAnonymous: map['isAnonymous'] ?? false,
      creationTime:
          map['creationTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['creationTime'])
              : null,
      lastSignInTime:
          map['lastSignInTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastSignInTime'])
              : null,
    );
  }

  /// Convertir le UserModel en Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'creationTime': creationTime?.millisecondsSinceEpoch,
      'lastSignInTime': lastSignInTime?.millisecondsSinceEpoch,
    };
  }

  /// Factory pour créer un UserModel vide
  factory UserModel.empty() {
    return const UserModel(
      uid: '',
      email: null,
      displayName: null,
      photoURL: null,
      phoneNumber: null,
      emailVerified: false,
      isAnonymous: false,
      creationTime: null,
      lastSignInTime: null,
    );
  }

  /// Vérifier si l'utilisateur est vide
  bool get isEmpty => uid.isEmpty;

  /// Vérifier si l'utilisateur n'est pas vide
  bool get isNotEmpty => !isEmpty;

  /// Obtenir le nom d'affichage ou l'email si le nom n'est pas disponible
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return phoneNumber!;
    }
    return 'Utilisateur';
  }

  /// Obtenir les initiales du nom d'affichage
  String get initials {
    final name = displayNameOrEmail;
    if (name.isEmpty) return 'U';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Créer une copie du UserModel avec des modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    bool? isAnonymous,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      creationTime: creationTime ?? this.creationTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    phoneNumber,
    emailVerified,
    isAnonymous,
    creationTime,
    lastSignInTime,
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
        'photoURL: $photoURL, phoneNumber: $phoneNumber, '
        'emailVerified: $emailVerified, isAnonymous: $isAnonymous, '
        'creationTime: $creationTime, lastSignInTime: $lastSignInTime)';
  }
}

/// Énumération pour les types d'authentification
enum AuthProvider { email, phone, google, anonymous }

/// Extension pour obtenir le provider d'authentification à partir d'un UserModel
extension UserModelAuthProvider on UserModel {
  /// Obtenir le type de provider d'authentification principal
  AuthProvider get primaryAuthProvider {
    if (isAnonymous) return AuthProvider.anonymous;
    if (email != null && email!.contains('@')) return AuthProvider.email;
    if (phoneNumber != null) return AuthProvider.phone;
    return AuthProvider.email; // Par défaut
  }

  /// Vérifier si l'utilisateur peut se connecter avec le téléphone
  bool get canSignInWithPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
}
