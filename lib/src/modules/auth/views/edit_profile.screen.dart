import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/validators.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_dialogs.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:kartia/src/widgets/kartia_texfield.widget.dart';

/// Page de modification du profil utilisateur
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPasswordChangeMode = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initializeForm();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
  }

  void _initializeForm() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      _displayNameController.text = authState.user!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choisir une photo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: heightSpace.height!),

                Row(
                  children: [
                    Expanded(
                      child: _buildImagePickerOption(
                        icon: Icons.camera_alt,
                        label: 'Appareil photo',
                        onTap: () => _selectImage(ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: widthSpace.width!),
                    Expanded(
                      child: _buildImagePickerOption(
                        icon: Icons.photo_library,
                        label: 'Galerie',
                        onTap: () => _selectImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),

                if (_selectedImage != null) ...[
                  SizedBox(height: heightSpace.height!),
                  KartiaButton(
                    text: 'Supprimer la photo',
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _hasUnsavedChanges = true;
                      });
                      Navigator.pop(context);
                    },
                    type: KartiaButtonType.text,
                    textColor: AppColors.error,
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    Navigator.pop(context);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      KartiaSnackbar.show(
        // ignore: use_build_context_synchronously
        context,
        message: 'Erreur lors de la sélection de l\'image: $e',
        type: SnackbarType.error,
      );
    }
  }

  void _handleSaveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = context.read<AuthBloc>().state.user;
      if (currentUser == null) return;

      // Mettre à jour le profil
      String? newDisplayName =
          _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : null;

      String? newPhotoURL;
      if (_selectedImage != null) {
        // Ici, vous devriez uploader l'image vers Firebase Storage
        // et obtenir l'URL de téléchargement
        newPhotoURL = null; // Placeholder
      }

      context.read<AuthBloc>().add(
        AuthUpdateUserProfileRequested(
          displayName: newDisplayName,
          photoURL: newPhotoURL,
        ),
      );

      // Changer le mot de passe si demandé
      if (_isPasswordChangeMode && _newPasswordController.text.isNotEmpty) {
        context.read<AuthBloc>().add(
          AuthUpdatePasswordRequested(newPassword: _newPasswordController.text),
        );
      }

      setState(() {
        _hasUnsavedChanges = false;
      });
    }
  }

  void _handleCancel() {
    if (_hasUnsavedChanges) {
      KartiaDialogs.showCustomDialog(
        context,
        title: 'Modifications non sauvegardées',
        content: const Text('Voulez-vous vraiment annuler vos modifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer l\'édition'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Annuler les modifications'),
          ),
        ],
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _handleCancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le profil'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleCancel,
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.isLoading ? null : _handleSaveProfile,
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(
                      color:
                          state.isLoading
                              ? AppColors.mediumGrey
                              : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.hasError) {
              KartiaSnackbar.show(
                context,
                message: state.errorMessage!,
                type: SnackbarType.error,
              );
            } else if (state.isAuthenticated &&
                !state.isLoading &&
                !_hasUnsavedChanges) {
              KartiaSnackbar.show(
                context,
                message: 'Profil mis à jour avec succès !',
                type: SnackbarType.success,
              );
              context.pop();
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(fixPadding),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state.user;
                  final isLoading = state.isLoading;

                  if (user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Form(
                    key: _formKey,
                    onChanged: () {
                      setState(() {
                        _hasUnsavedChanges = true;
                      });
                    },
                    child: Column(
                      children: [
                        _buildProfilePictureSection(user),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildPersonalInfoSection(user, isLoading),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildPasswordSection(user, isLoading),
                        SizedBox(height: heightSpace.height! * 3),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Photo de profil',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: heightSpace.height!),

          // Avatar avec option de modification
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withAlpha(10),
                backgroundImage:
                    _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null),
                child:
                    _selectedImage == null && user.photoURL == null
                        ? Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                        : null,
              ),

              // Bouton de modification
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: heightSpace.height!),

          Text(
            'Touchez l\'icône pour changer votre photo',
            style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(user, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: heightSpace.height!),

          // Nom d'affichage
          KartiaTextField(
            controller: _displayNameController,
            labelText: 'Nom d\'affichage',
            hintText: 'Votre nom complet',
            prefixIcon: Icons.person_outline,
            enabled: !isLoading,
            validator: (value) {
              // Le nom d'affichage est optionnel
              return null;
            },
          ),
          SizedBox(height: heightSpace.height!),

          // Email (lecture seule)
          KartiaTextField(
            labelText: 'Adresse email',
            hintText: user.email ?? 'Aucun email',
            prefixIcon: Icons.email_outlined,
            enabled: false,
            suffixWidget:
                user.emailVerified
                    ? Icon(Icons.verified, color: AppColors.success)
                    : Icon(Icons.warning, color: AppColors.warning),
          ),

          if (user.phoneNumber != null) ...[
            SizedBox(height: heightSpace.height!),
            // Téléphone (lecture seule)
            KartiaTextField(
              labelText: 'Numéro de téléphone',
              hintText: user.phoneNumber!,
              prefixIcon: Icons.phone_outlined,
              enabled: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordSection(user, bool isLoading) {
    // Ne pas afficher la section mot de passe pour les comptes anonymes ou Google
    if (user.isAnonymous || user.email == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mot de passe',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isPasswordChangeMode,
                onChanged:
                    isLoading
                        ? null
                        : (value) {
                          setState(() {
                            _isPasswordChangeMode = value;
                            if (!value) {
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                activeColor: AppColors.primary,
              ),
            ],
          ),

          if (_isPasswordChangeMode) ...[
            SizedBox(height: heightSpace.height!),
            Text(
              'Changer votre mot de passe',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
            ),
            SizedBox(height: heightSpace.height!),

            // Nouveau mot de passe
            KartiaPasswordField(
              controller: _newPasswordController,
              labelText: 'Nouveau mot de passe',
              hintText: 'Minimum 6 caractères',
              enabled: !isLoading,
              validator: (value) {
                if (_isPasswordChangeMode && (value?.isEmpty ?? true)) {
                  return 'Veuillez entrer un nouveau mot de passe';
                }
                if (_isPasswordChangeMode &&
                    !Validators.isValidPassword(value!)) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            SizedBox(height: heightSpace.height!),

            // Confirmer le nouveau mot de passe
            KartiaPasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirmer le nouveau mot de passe',
              hintText: 'Retapez votre nouveau mot de passe',
              enabled: !isLoading,
              validator: (value) {
                if (_isPasswordChangeMode && (value?.isEmpty ?? true)) {
                  return 'Veuillez confirmer votre nouveau mot de passe';
                }
                if (_isPasswordChangeMode &&
                    !Validators.isValidCPassword(
                      _newPasswordController.text,
                      value!,
                    )) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            SizedBox(height: heightSpace.height!),

            // Note informative
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action peut nécessiter une reconnexion récente.',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: heightSpace.height! / 2),
            Text(
              'Activez l\'option pour changer votre mot de passe',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
