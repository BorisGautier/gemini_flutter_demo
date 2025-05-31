// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class KartiaLocalizations {
  KartiaLocalizations();

  static KartiaLocalizations? _current;

  static KartiaLocalizations get current {
    assert(
      _current != null,
      'No instance of KartiaLocalizations was loaded. Try to initialize the KartiaLocalizations delegate before accessing KartiaLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<KartiaLocalizations> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = KartiaLocalizations();
      KartiaLocalizations._current = instance;

      return instance;
    });
  }

  static KartiaLocalizations of(BuildContext context) {
    final instance = KartiaLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of KartiaLocalizations present in the widget tree. Did you add KartiaLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static KartiaLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<KartiaLocalizations>(context, KartiaLocalizations);
  }

  /// `Kartia`
  String get appname {
    return Intl.message('Kartia', name: 'appname', desc: '', args: []);
  }

  /// `Chargement...`
  String get loading {
    return Intl.message('Chargement...', name: 'loading', desc: '', args: []);
  }

  /// `Bienvenue !`
  String get welcome {
    return Intl.message('Bienvenue !', name: 'welcome', desc: '', args: []);
  }

  /// `Bienvenue sur Kartia !`
  String get welcomeBack {
    return Intl.message(
      'Bienvenue sur Kartia !',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Connectez-vous pour continuer`
  String get signInToContinue {
    return Intl.message(
      'Connectez-vous pour continuer',
      name: 'signInToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Créer un compte`
  String get createAccount {
    return Intl.message(
      'Créer un compte',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Rejoignez-nous dès maintenant`
  String get joinUsNow {
    return Intl.message(
      'Rejoignez-nous dès maintenant',
      name: 'joinUsNow',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe oublié ?`
  String get forgotPassword {
    return Intl.message(
      'Mot de passe oublié ?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Récupération`
  String get forgotPasswordTitle {
    return Intl.message(
      'Récupération',
      name: 'forgotPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe oublié ?`
  String get resetPassword {
    return Intl.message(
      'Mot de passe oublié ?',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Authentification par téléphone`
  String get phoneAuth {
    return Intl.message(
      'Authentification par téléphone',
      name: 'phoneAuth',
      desc: '',
      args: [],
    );
  }

  /// `Vérification`
  String get verification {
    return Intl.message(
      'Vérification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Votre numéro`
  String get yourNumber {
    return Intl.message('Votre numéro', name: 'yourNumber', desc: '', args: []);
  }

  /// `Profil`
  String get profile {
    return Intl.message('Profil', name: 'profile', desc: '', args: []);
  }

  /// `Modifier le profil`
  String get editProfile {
    return Intl.message(
      'Modifier le profil',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Adresse email`
  String get email {
    return Intl.message('Adresse email', name: 'email', desc: '', args: []);
  }

  /// `exemple@email.com`
  String get emailHint {
    return Intl.message(
      'exemple@email.com',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe`
  String get password {
    return Intl.message('Mot de passe', name: 'password', desc: '', args: []);
  }

  /// `Entrez votre mot de passe`
  String get passwordHint {
    return Intl.message(
      'Entrez votre mot de passe',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirmer le mot de passe`
  String get confirmPassword {
    return Intl.message(
      'Confirmer le mot de passe',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Retapez votre mot de passe`
  String get confirmPasswordHint {
    return Intl.message(
      'Retapez votre mot de passe',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Nouveau mot de passe`
  String get newPassword {
    return Intl.message(
      'Nouveau mot de passe',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 6 caractères`
  String get newPasswordHint {
    return Intl.message(
      'Minimum 6 caractères',
      name: 'newPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Nom complet (optionnel)`
  String get displayName {
    return Intl.message(
      'Nom complet (optionnel)',
      name: 'displayName',
      desc: '',
      args: [],
    );
  }

  /// `Jean Dupont`
  String get displayNameHint {
    return Intl.message(
      'Jean Dupont',
      name: 'displayNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Nom d'affichage`
  String get displayNameProfile {
    return Intl.message(
      'Nom d\'affichage',
      name: 'displayNameProfile',
      desc: '',
      args: [],
    );
  }

  /// `Numéro de téléphone`
  String get phoneNumber {
    return Intl.message(
      'Numéro de téléphone',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Code de vérification`
  String get verificationCode {
    return Intl.message(
      'Code de vérification',
      name: 'verificationCode',
      desc: '',
      args: [],
    );
  }

  /// `XXXXXX`
  String get verificationCodeHint {
    return Intl.message(
      'XXXXXX',
      name: 'verificationCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Se connecter`
  String get signIn {
    return Intl.message('Se connecter', name: 'signIn', desc: '', args: []);
  }

  /// `S'inscrire`
  String get signUp {
    return Intl.message('S\'inscrire', name: 'signUp', desc: '', args: []);
  }

  /// `Se déconnecter`
  String get signOut {
    return Intl.message('Se déconnecter', name: 'signOut', desc: '', args: []);
  }

  /// `S'inscrire`
  String get register {
    return Intl.message('S\'inscrire', name: 'register', desc: '', args: []);
  }

  /// `Sauvegarder`
  String get save {
    return Intl.message('Sauvegarder', name: 'save', desc: '', args: []);
  }

  /// `Annuler`
  String get cancel {
    return Intl.message('Annuler', name: 'cancel', desc: '', args: []);
  }

  /// `Réessayer`
  String get retry {
    return Intl.message('Réessayer', name: 'retry', desc: '', args: []);
  }

  /// `Renvoyer`
  String get resend {
    return Intl.message('Renvoyer', name: 'resend', desc: '', args: []);
  }

  /// `Vérifier`
  String get verify {
    return Intl.message('Vérifier', name: 'verify', desc: '', args: []);
  }

  /// `Envoyer`
  String get send {
    return Intl.message('Envoyer', name: 'send', desc: '', args: []);
  }

  /// `Envoyer le code`
  String get sendCode {
    return Intl.message(
      'Envoyer le code',
      name: 'sendCode',
      desc: '',
      args: [],
    );
  }

  /// `Envoyer le lien`
  String get sendLink {
    return Intl.message(
      'Envoyer le lien',
      name: 'sendLink',
      desc: '',
      args: [],
    );
  }

  /// `Continuer en tant qu'invité`
  String get continueAsGuest {
    return Intl.message(
      'Continuer en tant qu\'invité',
      name: 'continueAsGuest',
      desc: '',
      args: [],
    );
  }

  /// `ou continuer avec`
  String get orContinueWith {
    return Intl.message(
      'ou continuer avec',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `ou s'inscrire avec`
  String get orSignUpWith {
    return Intl.message(
      'ou s\'inscrire avec',
      name: 'orSignUpWith',
      desc: '',
      args: [],
    );
  }

  /// `Google`
  String get google {
    return Intl.message('Google', name: 'google', desc: '', args: []);
  }

  /// `Téléphone`
  String get phone {
    return Intl.message('Téléphone', name: 'phone', desc: '', args: []);
  }

  /// `Appareil photo`
  String get camera {
    return Intl.message('Appareil photo', name: 'camera', desc: '', args: []);
  }

  /// `Galerie`
  String get gallery {
    return Intl.message('Galerie', name: 'gallery', desc: '', args: []);
  }

  /// `Supprimer la photo`
  String get removePhoto {
    return Intl.message(
      'Supprimer la photo',
      name: 'removePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Touchez l'icône pour changer votre photo`
  String get changePhoto {
    return Intl.message(
      'Touchez l\'icône pour changer votre photo',
      name: 'changePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Email envoyé !`
  String get emailSent {
    return Intl.message(
      'Email envoyé !',
      name: 'emailSent',
      desc: '',
      args: [],
    );
  }

  /// `Nous avons envoyé un lien de récupération à`
  String get emailSentSuccess {
    return Intl.message(
      'Nous avons envoyé un lien de récupération à',
      name: 'emailSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Vérifiez votre boîte mail`
  String get checkEmail {
    return Intl.message(
      'Vérifiez votre boîte mail',
      name: 'checkEmail',
      desc: '',
      args: [],
    );
  }

  /// `Cliquez sur le lien dans l'email pour réinitialiser votre mot de passe.`
  String get clickLinkInEmail {
    return Intl.message(
      'Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
      name: 'clickLinkInEmail',
      desc: '',
      args: [],
    );
  }

  /// `Renvoyer l'email`
  String get resendEmail {
    return Intl.message(
      'Renvoyer l\'email',
      name: 'resendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Essayer avec un autre email`
  String get tryAnotherEmail {
    return Intl.message(
      'Essayer avec un autre email',
      name: 'tryAnotherEmail',
      desc: '',
      args: [],
    );
  }

  /// `Vous ne trouvez pas l'email ?`
  String get cantFindEmail {
    return Intl.message(
      'Vous ne trouvez pas l\'email ?',
      name: 'cantFindEmail',
      desc: '',
      args: [],
    );
  }

  /// `• Vérifiez votre dossier spam\n• Assurez-vous que l'adresse email est correcte\n• L'email peut prendre quelques minutes à arriver`
  String get emailInstructions {
    return Intl.message(
      '• Vérifiez votre dossier spam\n• Assurez-vous que l\'adresse email est correcte\n• L\'email peut prendre quelques minutes à arriver',
      name: 'emailInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Entrez votre email pour recevoir un lien de récupération`
  String get enterEmailForReset {
    return Intl.message(
      'Entrez votre email pour recevoir un lien de récupération',
      name: 'enterEmailForReset',
      desc: '',
      args: [],
    );
  }

  /// `Un email avec un lien de récupération sera envoyé à cette adresse.`
  String get resetLinkWillBeSent {
    return Intl.message(
      'Un email avec un lien de récupération sera envoyé à cette adresse.',
      name: 'resetLinkWillBeSent',
      desc: '',
      args: [],
    );
  }

  /// `Entrez le code reçu par SMS`
  String get enterCodeReceived {
    return Intl.message(
      'Entrez le code reçu par SMS',
      name: 'enterCodeReceived',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le numéro`
  String get changeNumber {
    return Intl.message(
      'Modifier le numéro',
      name: 'changeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Nous vous enverrons un code de vérification`
  String get phoneWillReceiveCode {
    return Intl.message(
      'Nous vous enverrons un code de vérification',
      name: 'phoneWillReceiveCode',
      desc: '',
      args: [],
    );
  }

  /// `Un code de vérification sera envoyé par SMS à ce numéro.`
  String get codeWillBeSent {
    return Intl.message(
      'Un code de vérification sera envoyé par SMS à ce numéro.',
      name: 'codeWillBeSent',
      desc: '',
      args: [],
    );
  }

  /// `Renvoyer le code dans {seconds}s`
  String resendCodeIn(int seconds) {
    return Intl.message(
      'Renvoyer le code dans ${seconds}s',
      name: 'resendCodeIn',
      desc: '',
      args: [seconds],
    );
  }

  /// `Renvoyer le code`
  String get resendCode {
    return Intl.message(
      'Renvoyer le code',
      name: 'resendCode',
      desc: '',
      args: [],
    );
  }

  /// `Déjà un compte ? `
  String get alreadyHaveAccount {
    return Intl.message(
      'Déjà un compte ? ',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Pas encore de compte ? `
  String get noAccount {
    return Intl.message(
      'Pas encore de compte ? ',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Vous vous souvenez ? `
  String get rememberPassword {
    return Intl.message(
      'Vous vous souvenez ? ',
      name: 'rememberPassword',
      desc: '',
      args: [],
    );
  }

  /// `J'accepte les `
  String get acceptTerms {
    return Intl.message(
      'J\'accepte les ',
      name: 'acceptTerms',
      desc: '',
      args: [],
    );
  }

  /// `conditions d'utilisation`
  String get termsOfService {
    return Intl.message(
      'conditions d\'utilisation',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `politique de confidentialité`
  String get privacyPolicy {
    return Intl.message(
      'politique de confidentialité',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// ` et la `
  String get and {
    return Intl.message(' et la ', name: 'and', desc: '', args: []);
  }

  /// `Veuillez accepter les conditions d'utilisation`
  String get pleaseAcceptTerms {
    return Intl.message(
      'Veuillez accepter les conditions d\'utilisation',
      name: 'pleaseAcceptTerms',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 Kartia. Tous droits réservés.`
  String get copyright {
    return Intl.message(
      '© 2025 Kartia. Tous droits réservés.',
      name: 'copyright',
      desc: '',
      args: [],
    );
  }

  /// `Informations personnelles`
  String get personalInformation {
    return Intl.message(
      'Informations personnelles',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Photo de profil`
  String get profilePicture {
    return Intl.message(
      'Photo de profil',
      name: 'profilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Statut du compte`
  String get accountStatus {
    return Intl.message(
      'Statut du compte',
      name: 'accountStatus',
      desc: '',
      args: [],
    );
  }

  /// `Compte invité`
  String get guestAccount {
    return Intl.message(
      'Compte invité',
      name: 'guestAccount',
      desc: '',
      args: [],
    );
  }

  /// `Email vérifié`
  String get emailVerified {
    return Intl.message(
      'Email vérifié',
      name: 'emailVerified',
      desc: '',
      args: [],
    );
  }

  /// `Email non vérifié`
  String get emailNotVerified {
    return Intl.message(
      'Email non vérifié',
      name: 'emailNotVerified',
      desc: '',
      args: [],
    );
  }

  /// `Vérifier l'email`
  String get verifyEmail {
    return Intl.message(
      'Vérifier l\'email',
      name: 'verifyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Mot de passe`
  String get passwordSection {
    return Intl.message(
      'Mot de passe',
      name: 'passwordSection',
      desc: '',
      args: [],
    );
  }

  /// `Changer votre mot de passe`
  String get changePassword {
    return Intl.message(
      'Changer votre mot de passe',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Zone de danger`
  String get dangerZone {
    return Intl.message(
      'Zone de danger',
      name: 'dangerZone',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer le compte`
  String get deleteAccount {
    return Intl.message(
      'Supprimer le compte',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Cette action est irréversible. Toutes vos données seront définitivement supprimées.`
  String get deleteAccountWarning {
    return Intl.message(
      'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
      name: 'deleteAccountWarning',
      desc: '',
      args: [],
    );
  }

  /// `Êtes-vous sûr de vouloir vous déconnecter ?`
  String get signOutConfirm {
    return Intl.message(
      'Êtes-vous sûr de vouloir vous déconnecter ?',
      name: 'signOutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Supprimer le compte`
  String get deleteAccountConfirm {
    return Intl.message(
      'Supprimer le compte',
      name: 'deleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Modifications non sauvegardées`
  String get unsavedChanges {
    return Intl.message(
      'Modifications non sauvegardées',
      name: 'unsavedChanges',
      desc: '',
      args: [],
    );
  }

  /// `Voulez-vous vraiment annuler vos modifications ?`
  String get unsavedChangesMessage {
    return Intl.message(
      'Voulez-vous vraiment annuler vos modifications ?',
      name: 'unsavedChangesMessage',
      desc: '',
      args: [],
    );
  }

  /// `Continuer l'édition`
  String get continueEditing {
    return Intl.message(
      'Continuer l\'édition',
      name: 'continueEditing',
      desc: '',
      args: [],
    );
  }

  /// `Annuler les modifications`
  String get discardChanges {
    return Intl.message(
      'Annuler les modifications',
      name: 'discardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Profil mis à jour avec succès !`
  String get profileUpdatedSuccess {
    return Intl.message(
      'Profil mis à jour avec succès !',
      name: 'profileUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Un email de vérification a été envoyé à votre adresse.`
  String get emailVerificationSent {
    return Intl.message(
      'Un email de vérification a été envoyé à votre adresse.',
      name: 'emailVerificationSent',
      desc: '',
      args: [],
    );
  }

  /// `Cette action peut nécessiter une reconnexion récente.`
  String get recentLoginRequired {
    return Intl.message(
      'Cette action peut nécessiter une reconnexion récente.',
      name: 'recentLoginRequired',
      desc: '',
      args: [],
    );
  }

  /// `Activez l'option pour changer votre mot de passe`
  String get enableToChange {
    return Intl.message(
      'Activez l\'option pour changer votre mot de passe',
      name: 'enableToChange',
      desc: '',
      args: [],
    );
  }

  /// `Accueil`
  String get home {
    return Intl.message('Accueil', name: 'home', desc: '', args: []);
  }

  /// `Services`
  String get services {
    return Intl.message('Services', name: 'services', desc: '', args: []);
  }

  /// `Paramètres`
  String get settings {
    return Intl.message('Paramètres', name: 'settings', desc: '', args: []);
  }

  /// `Bonjour,`
  String get hello {
    return Intl.message('Bonjour,', name: 'hello', desc: '', args: []);
  }

  /// `Invité`
  String get guest {
    return Intl.message('Invité', name: 'guest', desc: '', args: []);
  }

  /// `Utilisateur`
  String get user {
    return Intl.message('Utilisateur', name: 'user', desc: '', args: []);
  }

  /// `Bienvenue sur Kartia !`
  String get welcomeToKartia {
    return Intl.message(
      'Bienvenue sur Kartia !',
      name: 'welcomeToKartia',
      desc: '',
      args: [],
    );
  }

  /// `Découvrez nos services intelligents pour vous faciliter la vie au quotidien.`
  String get discoverServices {
    return Intl.message(
      'Découvrez nos services intelligents pour vous faciliter la vie au quotidien.',
      name: 'discoverServices',
      desc: '',
      args: [],
    );
  }

  /// `Explorer`
  String get explore {
    return Intl.message('Explorer', name: 'explore', desc: '', args: []);
  }

  /// `Actions rapides`
  String get quickActions {
    return Intl.message(
      'Actions rapides',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `Activité récente`
  String get recentActivity {
    return Intl.message(
      'Activité récente',
      name: 'recentActivity',
      desc: '',
      args: [],
    );
  }

  /// `Aucune activité récente`
  String get noRecentActivity {
    return Intl.message(
      'Aucune activité récente',
      name: 'noRecentActivity',
      desc: '',
      args: [],
    );
  }

  /// `Commencez à utiliser nos services pour voir votre activité ici.`
  String get startUsingServices {
    return Intl.message(
      'Commencez à utiliser nos services pour voir votre activité ici.',
      name: 'startUsingServices',
      desc: '',
      args: [],
    );
  }

  /// `Nos Services`
  String get ourServices {
    return Intl.message(
      'Nos Services',
      name: 'ourServices',
      desc: '',
      args: [],
    );
  }

  /// `Bientôt`
  String get comingSoon {
    return Intl.message('Bientôt', name: 'comingSoon', desc: '', args: []);
  }

  /// `{feature} - Bientôt disponible !`
  String comingSoonMessage(String feature) {
    return Intl.message(
      '$feature - Bientôt disponible !',
      name: 'comingSoonMessage',
      desc: '',
      args: [feature],
    );
  }

  /// `CityAI Guide`
  String get cityAiGuide {
    return Intl.message(
      'CityAI Guide',
      name: 'cityAiGuide',
      desc: '',
      args: [],
    );
  }

  /// `Navigation intelligente avec IA pour vous guider dans la ville`
  String get cityAiGuideDesc {
    return Intl.message(
      'Navigation intelligente avec IA pour vous guider dans la ville',
      name: 'cityAiGuideDesc',
      desc: '',
      args: [],
    );
  }

  /// `Santé Map`
  String get santeMap {
    return Intl.message('Santé Map', name: 'santeMap', desc: '', args: []);
  }

  /// `Trouvez les centres de santé les plus proches de vous`
  String get santeMapDesc {
    return Intl.message(
      'Trouvez les centres de santé les plus proches de vous',
      name: 'santeMapDesc',
      desc: '',
      args: [],
    );
  }

  /// `CivAct`
  String get civact {
    return Intl.message('CivAct', name: 'civact', desc: '', args: []);
  }

  /// `Plateforme d'action citoyenne et de signalement`
  String get civactDesc {
    return Intl.message(
      'Plateforme d\'action citoyenne et de signalement',
      name: 'civactDesc',
      desc: '',
      args: [],
    );
  }

  /// `Carto Prix`
  String get cartoPrix {
    return Intl.message('Carto Prix', name: 'cartoPrix', desc: '', args: []);
  }

  /// `Comparateur de prix pour vos achats quotidiens`
  String get cartoPrixDesc {
    return Intl.message(
      'Comparateur de prix pour vos achats quotidiens',
      name: 'cartoPrixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Compte`
  String get account {
    return Intl.message('Compte', name: 'account', desc: '', args: []);
  }

  /// `Apparence`
  String get appearance {
    return Intl.message('Apparence', name: 'appearance', desc: '', args: []);
  }

  /// `À propos`
  String get about {
    return Intl.message('À propos', name: 'about', desc: '', args: []);
  }

  /// `Thème`
  String get theme {
    return Intl.message('Thème', name: 'theme', desc: '', args: []);
  }

  /// `Basculer entre clair et sombre`
  String get themeDesc {
    return Intl.message(
      'Basculer entre clair et sombre',
      name: 'themeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Langue`
  String get language {
    return Intl.message('Langue', name: 'language', desc: '', args: []);
  }

  /// `Français / English`
  String get languageDesc {
    return Intl.message(
      'Français / English',
      name: 'languageDesc',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Aide`
  String get help {
    return Intl.message('Aide', name: 'help', desc: '', args: []);
  }

  /// `Support et FAQ`
  String get helpDesc {
    return Intl.message('Support et FAQ', name: 'helpDesc', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Gérer vos préférences de notification`
  String get notificationsDesc {
    return Intl.message(
      'Gérer vos préférences de notification',
      name: 'notificationsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Confidentialité`
  String get privacy {
    return Intl.message('Confidentialité', name: 'privacy', desc: '', args: []);
  }

  /// `Paramètres de confidentialité`
  String get privacyDesc {
    return Intl.message(
      'Paramètres de confidentialité',
      name: 'privacyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Gérer vos informations personnelles`
  String get manageProfile {
    return Intl.message(
      'Gérer vos informations personnelles',
      name: 'manageProfile',
      desc: '',
      args: [],
    );
  }

  /// `Modifier votre mot de passe`
  String get changePasswordDesc {
    return Intl.message(
      'Modifier votre mot de passe',
      name: 'changePasswordDesc',
      desc: '',
      args: [],
    );
  }

  /// `Déconnexion de votre compte`
  String get signOutDesc {
    return Intl.message(
      'Déconnexion de votre compte',
      name: 'signOutDesc',
      desc: '',
      args: [],
    );
  }

  /// `Suppression définitive de votre compte`
  String get deleteAccountDesc {
    return Intl.message(
      'Suppression définitive de votre compte',
      name: 'deleteAccountDesc',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer votre email`
  String get validationEmailRequired {
    return Intl.message(
      'Veuillez entrer votre email',
      name: 'validationEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer un email valide`
  String get validationEmailInvalid {
    return Intl.message(
      'Veuillez entrer un email valide',
      name: 'validationEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer votre mot de passe`
  String get validationPasswordRequired {
    return Intl.message(
      'Veuillez entrer votre mot de passe',
      name: 'validationPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Le mot de passe doit contenir au moins 6 caractères`
  String get validationPasswordMinLength {
    return Intl.message(
      'Le mot de passe doit contenir au moins 6 caractères',
      name: 'validationPasswordMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Les mots de passe ne correspondent pas`
  String get validationPasswordsDoNotMatch {
    return Intl.message(
      'Les mots de passe ne correspondent pas',
      name: 'validationPasswordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer votre numéro`
  String get validationPhoneRequired {
    return Intl.message(
      'Veuillez entrer votre numéro',
      name: 'validationPhoneRequired',
      desc: '',
      args: [],
    );
  }

  /// `Numéro invalide (9 chiffres requis)`
  String get validationPhoneInvalid {
    return Intl.message(
      'Numéro invalide (9 chiffres requis)',
      name: 'validationPhoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer le code`
  String get validationCodeRequired {
    return Intl.message(
      'Veuillez entrer le code',
      name: 'validationCodeRequired',
      desc: '',
      args: [],
    );
  }

  /// `Le code doit contenir 6 chiffres`
  String get validationCodeLength {
    return Intl.message(
      'Le code doit contenir 6 chiffres',
      name: 'validationCodeLength',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez confirmer votre nouveau mot de passe`
  String get validationConfirmPasswordRequired {
    return Intl.message(
      'Veuillez confirmer votre nouveau mot de passe',
      name: 'validationConfirmPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Veuillez entrer un nouveau mot de passe`
  String get validationNewPasswordRequired {
    return Intl.message(
      'Veuillez entrer un nouveau mot de passe',
      name: 'validationNewPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Erreur de chargement...`
  String get errorLoadingFailed {
    return Intl.message(
      'Erreur de chargement...',
      name: 'errorLoadingFailed',
      desc: '',
      args: [],
    );
  }

  /// `Erreur lors de la sélection de l'image: {error}`
  String errorImageSelection(String error) {
    return Intl.message(
      'Erreur lors de la sélection de l\'image: $error',
      name: 'errorImageSelection',
      desc: '',
      args: [error],
    );
  }

  /// `Une erreur inattendue s'est produite`
  String get errorUnexpected {
    return Intl.message(
      'Une erreur inattendue s\'est produite',
      name: 'errorUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `Cette fonctionnalité sera bientôt disponible.`
  String get featureComingSoon {
    return Intl.message(
      'Cette fonctionnalité sera bientôt disponible.',
      name: 'featureComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Démarrage...`
  String get splashStarting {
    return Intl.message(
      'Démarrage...',
      name: 'splashStarting',
      desc: '',
      args: [],
    );
  }

  /// `Chargement des ressources...`
  String get splashLoadingResources {
    return Intl.message(
      'Chargement des ressources...',
      name: 'splashLoadingResources',
      desc: '',
      args: [],
    );
  }

  /// `Initialisation...`
  String get splashInitializing {
    return Intl.message(
      'Initialisation...',
      name: 'splashInitializing',
      desc: '',
      args: [],
    );
  }

  /// `Prêt !`
  String get splashReady {
    return Intl.message('Prêt !', name: 'splashReady', desc: '', args: []);
  }

  /// `Votre assistant intelligent`
  String get splashSlogan {
    return Intl.message(
      'Votre assistant intelligent',
      name: 'splashSlogan',
      desc: '',
      args: [],
    );
  }

  /// `Version 1.0.0`
  String get splashVersion {
    return Intl.message(
      'Version 1.0.0',
      name: 'splashVersion',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 Kartia`
  String get splashCopyright {
    return Intl.message(
      '© 2025 Kartia',
      name: 'splashCopyright',
      desc: '',
      args: [],
    );
  }

  /// `Choisir une photo`
  String get choosePhoto {
    return Intl.message(
      'Choisir une photo',
      name: 'choosePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Un accès GPS est nécessaire`
  String get gpsAccess {
    return Intl.message(
      'Un accès GPS est nécessaire',
      name: 'gpsAccess',
      desc: '',
      args: [],
    );
  }

  /// `Assurez-vous d'activer le GPS.`
  String get enableGps {
    return Intl.message(
      'Assurez-vous d\'activer le GPS.',
      name: 'enableGps',
      desc: '',
      args: [],
    );
  }

  /// `Demandez l'access`
  String get askAccess {
    return Intl.message(
      'Demandez l\'access',
      name: 'askAccess',
      desc: '',
      args: [],
    );
  }

  /// `GPS activé ! Nous avons maintenant besoin de votre permission pour accéder à votre localisation.`
  String get gpsEnabledMessage {
    return Intl.message(
      'GPS activé ! Nous avons maintenant besoin de votre permission pour accéder à votre localisation.',
      name: 'gpsEnabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Pour utiliser cette application, vous devez d'abord activer le GPS dans les paramètres de votre appareil.`
  String get gpsDisabledMessage {
    return Intl.message(
      'Pour utiliser cette application, vous devez d\'abord activer le GPS dans les paramètres de votre appareil.',
      name: 'gpsDisabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Demande de permission en cours...`
  String get permissionRequestInProgress {
    return Intl.message(
      'Demande de permission en cours...',
      name: 'permissionRequestInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Cette autorisation est nécessaire pour le bon fonctionnement de l'application.`
  String get locationPermissionRequired {
    return Intl.message(
      'Cette autorisation est nécessaire pour le bon fonctionnement de l\'application.',
      name: 'locationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Après avoir cliqué sur le lien, cette page se mettra automatiquement à jour.`
  String get emailVerificationInstructions {
    return Intl.message(
      'Après avoir cliqué sur le lien, cette page se mettra automatiquement à jour.',
      name: 'emailVerificationInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Nouvelle image sélectionnée. Cliquez sur "Sauvegarder" pour confirmer.`
  String get newImageSelected {
    return Intl.message(
      'Nouvelle image sélectionnée. Cliquez sur "Sauvegarder" pour confirmer.',
      name: 'newImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `Nom d'utilisateur`
  String get usernamePlaceholder {
    return Intl.message(
      'Nom d\'utilisateur',
      name: 'usernamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Modifier le mot de passe`
  String get changePasswordOption {
    return Intl.message(
      'Modifier le mot de passe',
      name: 'changePasswordOption',
      desc: '',
      args: [],
    );
  }

  /// `Image sélectionnée. N'oubliez pas de sauvegarder.`
  String get imageSelectedMessage {
    return Intl.message(
      'Image sélectionnée. N\'oubliez pas de sauvegarder.',
      name: 'imageSelectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Choisir la méthode`
  String get chooseMethod {
    return Intl.message(
      'Choisir la méthode',
      name: 'chooseMethod',
      desc: '',
      args: [],
    );
  }

  /// `Passer à un Compte Complet`
  String get upgradeToFullAccount {
    return Intl.message(
      'Passer à un Compte Complet',
      name: 'upgradeToFullAccount',
      desc: '',
      args: [],
    );
  }

  /// `Entrez le code de vérification envoyé au {phoneNumber}`
  String enterSmsCodeMessage(String phoneNumber) {
    return Intl.message(
      'Entrez le code de vérification envoyé au $phoneNumber',
      name: 'enterSmsCodeMessage',
      desc: '',
      args: [phoneNumber],
    );
  }

  /// `Transformez votre compte invité en compte permanent pour bénéficier de toutes les fonctionnalités.`
  String get upgradeAccountDescription {
    return Intl.message(
      'Transformez votre compte invité en compte permanent pour bénéficier de toutes les fonctionnalités.',
      name: 'upgradeAccountDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarder vos données`
  String get saveYourData {
    return Intl.message(
      'Sauvegarder vos données',
      name: 'saveYourData',
      desc: '',
      args: [],
    );
  }

  /// `Synchronisation multi-appareils`
  String get multiDeviceSync {
    return Intl.message(
      'Synchronisation multi-appareils',
      name: 'multiDeviceSync',
      desc: '',
      args: [],
    );
  }

  /// `Sécurité renforcée`
  String get enhancedSecurity {
    return Intl.message(
      'Sécurité renforcée',
      name: 'enhancedSecurity',
      desc: '',
      args: [],
    );
  }

  /// `Sauvegarde automatique`
  String get automaticBackup {
    return Intl.message(
      'Sauvegarde automatique',
      name: 'automaticBackup',
      desc: '',
      args: [],
    );
  }

  /// `Informations du Compte Email`
  String get emailAccountInfo {
    return Intl.message(
      'Informations du Compte Email',
      name: 'emailAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `Informations du Compte Téléphone`
  String get phoneAccountInfo {
    return Intl.message(
      'Informations du Compte Téléphone',
      name: 'phoneAccountInfo',
      desc: '',
      args: [],
    );
  }

  /// `6XX XXX XXX (sans +237)`
  String get phoneNumberHintCameroon {
    return Intl.message(
      '6XX XXX XXX (sans +237)',
      name: 'phoneNumberHintCameroon',
      desc: '',
      args: [],
    );
  }

  /// `Créer mon Compte Email`
  String get createEmailAccount {
    return Intl.message(
      'Créer mon Compte Email',
      name: 'createEmailAccount',
      desc: '',
      args: [],
    );
  }

  /// `Envoyer le Code SMS`
  String get sendSmsCode {
    return Intl.message(
      'Envoyer le Code SMS',
      name: 'sendSmsCode',
      desc: '',
      args: [],
    );
  }

  /// `Vérifier le Code`
  String get verifyCode {
    return Intl.message(
      'Vérifier le Code',
      name: 'verifyCode',
      desc: '',
      args: [],
    );
  }

  /// `Changer de numéro`
  String get changePhoneNumber {
    return Intl.message(
      'Changer de numéro',
      name: 'changePhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Synchroniser`
  String get syncData {
    return Intl.message('Synchroniser', name: 'syncData', desc: '', args: []);
  }

  /// `Changer le thème`
  String get changeTheme {
    return Intl.message(
      'Changer le thème',
      name: 'changeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Changer la langue`
  String get changeLanguage {
    return Intl.message(
      'Changer la langue',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Synchronisation des données en cours...`
  String get syncInProgress {
    return Intl.message(
      'Synchronisation des données en cours...',
      name: 'syncInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Données mises à jour`
  String get dataUpdated {
    return Intl.message(
      'Données mises à jour',
      name: 'dataUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Synchronisation`
  String get syncDataOption {
    return Intl.message(
      'Synchronisation',
      name: 'syncDataOption',
      desc: '',
      args: [],
    );
  }

  /// `Synchroniser les données utilisateur`
  String get syncUserData {
    return Intl.message(
      'Synchroniser les données utilisateur',
      name: 'syncUserData',
      desc: '',
      args: [],
    );
  }

  /// `Développeur`
  String get developer {
    return Intl.message('Développeur', name: 'developer', desc: '', args: []);
  }

  /// `Infos de Debug`
  String get debugInfo {
    return Intl.message(
      'Infos de Debug',
      name: 'debugInfo',
      desc: '',
      args: [],
    );
  }

  /// `Dernière sync: {timestamp}`
  String lastSyncMessage(String timestamp) {
    return Intl.message(
      'Dernière sync: $timestamp',
      name: 'lastSyncMessage',
      desc: '',
      args: [timestamp],
    );
  }

  /// `Aucune donnée Firestore`
  String get noFirestoreData {
    return Intl.message(
      'Aucune donnée Firestore',
      name: 'noFirestoreData',
      desc: '',
      args: [],
    );
  }

  /// `État Auth`
  String get authState {
    return Intl.message('État Auth', name: 'authState', desc: '', args: []);
  }

  /// `Utilisateur`
  String get userId {
    return Intl.message('Utilisateur', name: 'userId', desc: '', args: []);
  }

  /// `Firestore`
  String get firestoreData {
    return Intl.message('Firestore', name: 'firestoreData', desc: '', args: []);
  }

  /// `Dernière sync`
  String get lastSync {
    return Intl.message('Dernière sync', name: 'lastSync', desc: '', args: []);
  }

  /// `jamais`
  String get never {
    return Intl.message('jamais', name: 'never', desc: '', args: []);
  }

  /// `Localisation active`
  String get locationActive {
    return Intl.message(
      'Localisation active',
      name: 'locationActive',
      desc: '',
      args: [],
    );
  }

  /// `Version app`
  String get appVersion {
    return Intl.message('Version app', name: 'appVersion', desc: '', args: []);
  }

  /// `Plateforme`
  String get platform {
    return Intl.message('Plateforme', name: 'platform', desc: '', args: []);
  }

  /// `OS`
  String get osVersion {
    return Intl.message('OS', name: 'osVersion', desc: '', args: []);
  }

  /// `Pays`
  String get country {
    return Intl.message('Pays', name: 'country', desc: '', args: []);
  }

  /// `Position`
  String get position {
    return Intl.message('Position', name: 'position', desc: '', args: []);
  }

  /// `Options du Profil`
  String get profileOptions {
    return Intl.message(
      'Options du Profil',
      name: 'profileOptions',
      desc: '',
      args: [],
    );
  }

  /// `Téléphone Vérifié`
  String get phoneVerified {
    return Intl.message(
      'Téléphone Vérifié',
      name: 'phoneVerified',
      desc: '',
      args: [],
    );
  }

  /// `Vous utilisez un compte invité. Créez un compte complet pour sauvegarder vos données et accéder à toutes les fonctionnalités.`
  String get guestAccountDescription {
    return Intl.message(
      'Vous utilisez un compte invité. Créez un compte complet pour sauvegarder vos données et accéder à toutes les fonctionnalités.',
      name: 'guestAccountDescription',
      desc: '',
      args: [],
    );
  }

  /// `Votre numéro de téléphone a été vérifié avec succès. Vous avez accès à toutes les fonctionnalités.`
  String get phoneVerifiedDescription {
    return Intl.message(
      'Votre numéro de téléphone a été vérifié avec succès. Vous avez accès à toutes les fonctionnalités.',
      name: 'phoneVerifiedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Votre adresse email a été vérifiée avec succès. Vous avez accès à toutes les fonctionnalités.`
  String get emailVerifiedDescription {
    return Intl.message(
      'Votre adresse email a été vérifiée avec succès. Vous avez accès à toutes les fonctionnalités.',
      name: 'emailVerifiedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Votre adresse email n'est pas encore vérifiée. Vérifiez votre email pour accéder à toutes les fonctionnalités.`
  String get emailNotVerifiedDescription {
    return Intl.message(
      'Votre adresse email n\'est pas encore vérifiée. Vérifiez votre email pour accéder à toutes les fonctionnalités.',
      name: 'emailNotVerifiedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Passez d'un compte invité à un compte complet pour :`
  String get upgradeAccountBenefits {
    return Intl.message(
      'Passez d\'un compte invité à un compte complet pour :',
      name: 'upgradeAccountBenefits',
      desc: '',
      args: [],
    );
  }

  /// `Vos données actuelles seront conservées lors de la migration.`
  String get dataWillBePreserved {
    return Intl.message(
      'Vos données actuelles seront conservées lors de la migration.',
      name: 'dataWillBePreserved',
      desc: '',
      args: [],
    );
  }

  /// `Notifications personnalisées`
  String get personalizedNotifications {
    return Intl.message(
      'Notifications personnalisées',
      name: 'personalizedNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Créer avec Email`
  String get createWithEmail {
    return Intl.message(
      'Créer avec Email',
      name: 'createWithEmail',
      desc: '',
      args: [],
    );
  }

  /// `Créer avec Téléphone`
  String get createWithPhone {
    return Intl.message(
      'Créer avec Téléphone',
      name: 'createWithPhone',
      desc: '',
      args: [],
    );
  }

  /// `Plus tard`
  String get later {
    return Intl.message('Plus tard', name: 'later', desc: '', args: []);
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<KartiaLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<KartiaLocalizations> load(Locale locale) =>
      KartiaLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
