part of 'gps_bloc.dart'; // Importation du fichier gps_bloc.dart

class GpsState extends Equatable {
  // Définition de la classe GpsState qui étend Equatable
  final bool
  isGpsEnabled; // Propriété booléenne qui indique si le GPS est activé
  final bool
  isGpsPermissionGranted; // Propriété booléenne qui indique si la permission GPS est accordée
  final bool
  isLoading; // ✅ AJOUT: Propriété pour indiquer si une opération est en cours

  bool get isAllGranted =>
      isGpsEnabled &&
      isGpsPermissionGranted; // Propriété booléenne qui indique si le GPS est activé et la permission est accordée

  const GpsState({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
    this.isLoading = false, // ✅ AJOUT: Par défaut pas de chargement
  }); // Constructeur qui prend deux arguments booléens obligatoires

  GpsState copyWith({
    // Méthode qui renvoie une nouvelle instance de GpsState avec des valeurs mises à jour
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
    bool? isLoading, // ✅ AJOUT: Paramètre pour le loading
  }) => GpsState(
    isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
    isGpsPermissionGranted:
        isGpsPermissionGranted ?? this.isGpsPermissionGranted,
    isLoading: isLoading ?? this.isLoading, // ✅ AJOUT: Gestion du loading
  );

  @override
  List<Object> get props => [
    isGpsEnabled,
    isGpsPermissionGranted,
    isLoading, // ✅ AJOUT: Inclure dans les props pour Equatable
  ]; // Liste des propriétés utilisées pour comparer deux instances de GpsState

  @override
  String toString() =>
      '{isGpsEnabled: $isGpsEnabled, isGpsPermissionGranted: $isGpsPermissionGranted, isLoading: $isLoading}'; // ✅ AJOUT: Inclure loading dans toString
}
