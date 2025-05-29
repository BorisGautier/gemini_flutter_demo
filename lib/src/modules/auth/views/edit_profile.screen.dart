import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/validators.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/widgets/profile_avatar.widget.dart';
import 'package:kartia/src/modules/auth/widgets/profile_section.widget.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_dialogs.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:kartia/src/widgets/kartia_texfield.widget.dart';

/// Page d'édition de profil responsive et complète
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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scaleController.forward();
    });
  }

  void _initializeForm() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      _displayNameController.text =
          authState.firestoreUser?.fullName ??
          authState.user!.displayName ??
          '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = KartiaLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildImagePickerBottomSheet(l10n),
    );
  }

  Widget _buildImagePickerBottomSheet(KartiaLocalizations l10n) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getAdaptivePadding(context).horizontal,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusXL),
                topRight: Radius.circular(AppSizes.radiusXL),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.photo_camera, color: AppColors.white),
                const SizedBox(width: 12),
                Text(
                  l10n.choosePhoto,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ResponsiveUtils.getAdaptiveFontSize(
                      context,
                      baseFontSize: 18,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.getAdaptivePadding(context).horizontal,
            ),
            child: ResponsiveGrid(
              crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 3,
              children: [
                _buildImagePickerOption(
                  l10n,
                  icon: Icons.camera_alt,
                  label: l10n.camera,
                  onTap: () => _selectImage(ImageSource.camera),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                _buildImagePickerOption(
                  l10n,
                  icon: Icons.photo_library,
                  label: l10n.gallery,
                  onTap: () => _selectImage(ImageSource.gallery),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.primary],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedImage != null) ...[
            const Divider(),
            Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveUtils.getAdaptivePadding(context).horizontal,
                left: ResponsiveUtils.getAdaptivePadding(context).horizontal,
                right: ResponsiveUtils.getAdaptivePadding(context).horizontal,
              ),
              child: KartiaButton(
                text: l10n.removePhoto,
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _hasUnsavedChanges = true;
                  });
                  Navigator.pop(context);
                },
                type: KartiaButtonType.outline,
                textColor: AppColors.error,
                borderColor: AppColors.error,
                icon: Icons.delete_outline,
                width: double.infinity,
              ),
            ),
          ],
          SizedBox(
            height: ResponsiveUtils.getAdaptiveSpacing(
              context,
              AppSizes.spacingM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerOption(
    KartiaLocalizations l10n, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.getAdaptiveSpacing(context, AppSizes.spacingL),
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(30),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: ResponsiveUtils.getAdaptiveValue(context, 32),
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingS,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getAdaptiveFontSize(
                  context,
                  baseFontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final l10n = KartiaLocalizations.of(context);

    Navigator.pop(context);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        // ✅ Vérifier que le fichier existe et est valide
        final File imageFile = File(image.path);
        if (await imageFile.exists()) {
          setState(() {
            _selectedImage = imageFile;
            _hasUnsavedChanges = true;
          });

          // ✅ Afficher un message de confirmation
          KartiaSnackbar.show(
            // ignore: use_build_context_synchronously
            context,
            message: 'Image sélectionnée. N\'oubliez pas de sauvegarder.',
            type: SnackbarType.success,
          );
        } else {
          throw Exception('Le fichier image est introuvable');
        }
      }
    } catch (e) {
      KartiaSnackbar.show(
        // ignore: use_build_context_synchronously
        context,
        message: l10n.errorImageSelection(e.toString()),
        type: SnackbarType.error,
      );

      // ✅ Reset de l'image en cas d'erreur
      setState(() {
        _selectedImage = null;
      });
    }
  }

  void _handleSaveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = context.read<AuthBloc>().state.user;
      if (currentUser == null) return;

      String? newDisplayName =
          _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : null;

      // ✅ Gérer le cas où on veut garder l'image actuelle
      String? newPhotoURL;
      if (_selectedImage == null) {
        // Garder l'URL actuelle si aucune nouvelle image n'est sélectionnée
        newPhotoURL = currentUser.photoURL;
      }

      context.read<AuthBloc>().add(
        AuthUpdateUserProfileRequested(
          displayName: newDisplayName,
          photoURL: newPhotoURL,
          imageFile: _selectedImage, // ✅ Passer le fichier image sélectionné
        ),
      );

      // ✅ Gérer la mise à jour du mot de passe séparément
      if (_isPasswordChangeMode && _newPasswordController.text.isNotEmpty) {
        context.read<AuthBloc>().add(
          AuthUpdatePasswordRequested(newPassword: _newPasswordController.text),
        );
      }

      // ✅ Reset des changements locaux
      setState(() {
        _hasUnsavedChanges = false;
        _selectedImage = null; // Reset après sauvegarde
      });
    }
  }

  void _handleCancel() {
    final l10n = KartiaLocalizations.of(context);

    if (_hasUnsavedChanges) {
      KartiaDialogs.showCustomDialog(
        context,
        title: l10n.unsavedChanges,
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.continueEditing),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.discardChanges),
          ),
        ],
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _handleCancel();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withAlpha(10),
                AppColors.backgroundColor(context),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(l10n),
                Expanded(
                  child: BlocListener<AuthBloc, AuthState>(
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
                          message: l10n.profileUpdatedSuccess,
                          type: SnackbarType.success,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final user = state.user;
                            final firestoreUser = state.firestoreUser;
                            final isLoading = state.isLoading;

                            if (user == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return ResponsiveLayout(
                              mobile: _buildMobileLayout(
                                context,
                                user,
                                firestoreUser,
                                isLoading,
                                l10n,
                              ),
                              tablet: _buildTabletLayout(
                                context,
                                user,
                                firestoreUser,
                                isLoading,
                                l10n,
                              ),
                              desktop: _buildDesktopLayout(
                                context,
                                user,
                                firestoreUser,
                                isLoading,
                                l10n,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(KartiaLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.white),
          onPressed: _handleCancel,
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getAdaptiveFontSize(
              context,
              baseFontSize: 18,
            ),
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: state.isLoading ? null : _handleSaveProfile,
                  icon:
                      state.isLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.save_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                  label: Text(
                    l10n.save,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    user,
    firestoreUser,
    bool isLoading,
    KartiaLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
      child: Form(
        key: _formKey,
        onChanged: () {
          setState(() {
            _hasUnsavedChanges = true;
          });
        },
        child: Column(
          children: [
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _scaleAnimation,
              child: _buildProfilePictureSection(l10n, user, firestoreUser),
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingXL,
              ),
            ),
            _buildPersonalInfoSection(l10n, user, firestoreUser, isLoading),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingXL,
              ),
            ),
            _buildPasswordSection(l10n, user, isLoading),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingXXL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    user,
    firestoreUser,
    bool isLoading,
    KartiaLocalizations l10n,
  ) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _hasUnsavedChanges = true;
            });
          },
          child: Column(
            children: [
              const SizedBox(height: 32),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildProfilePictureSection(l10n, user, firestoreUser),
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPersonalInfoSection(
                      l10n,
                      user,
                      firestoreUser,
                      isLoading,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(child: _buildPasswordSection(l10n, user, isLoading)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    user,
    firestoreUser,
    bool isLoading,
    KartiaLocalizations l10n,
  ) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _hasUnsavedChanges = true;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildProfilePictureSection(
                        l10n,
                        user,
                        firestoreUser,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildPersonalInfoSection(
                      l10n,
                      user,
                      firestoreUser,
                      isLoading,
                    ),
                    const SizedBox(height: 32),
                    _buildPasswordSection(l10n, user, isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Section mise à jour pour utiliser le nouveau ProfileAvatar avec imageFile
  Widget _buildProfilePictureSection(
    KartiaLocalizations l10n,
    user,
    firestoreUser,
  ) {
    return ProfileSection(
      title: l10n.profilePicture,
      icon: Icons.photo_camera,
      gradient: AppColors.primaryGradient,
      children: [
        Column(
          children: [
            Stack(
              children: [
                // ✅ FIX: Utiliser le nouveau ProfileAvatar avec imageFile
                ProfileAvatar(
                  user: user,
                  firestoreUser: firestoreUser,
                  radius: ResponsiveUtils.getAdaptiveValue(context, 60),
                  showBadge: true, // ✅ Afficher le badge pour la nouvelle image
                  imageFile: _selectedImage, // ✅ Passer l'image sélectionnée
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.primaryPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.surfaceColor(context),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withAlpha(40),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _selectedImage != null
                            ? Icons.edit
                            : Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingM,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _selectedImage != null
                        ? AppColors.success.withAlpha(10)
                        : AppColors.info.withAlpha(10),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color:
                      _selectedImage != null
                          ? AppColors.success.withAlpha(30)
                          : AppColors.info.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedImage != null
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    color:
                        _selectedImage != null
                            ? AppColors.success
                            : AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedImage != null
                          ? 'Nouvelle image sélectionnée. Cliquez sur "Sauvegarder" pour confirmer.'
                          : l10n.changePhoto,
                      style: TextStyle(
                        color:
                            _selectedImage != null
                                ? AppColors.success
                                : AppColors.info,
                        fontSize: ResponsiveUtils.getAdaptiveFontSize(
                          context,
                          baseFontSize: 12,
                        ),
                        fontWeight:
                            _selectedImage != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(
    KartiaLocalizations l10n,
    user,
    firestoreUser,
    bool isLoading,
  ) {
    return ProfileSection(
      title: l10n.personalInformation,
      icon: Icons.person_outline,
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ),
      children: [
        Column(
          children: [
            KartiaTextField(
              controller: _displayNameController,
              labelText: l10n.displayNameProfile,
              hintText: l10n.displayNameHint,
              prefixIcon: Icons.person_outline,
              enabled: !isLoading,
              validator: (value) {
                // Le nom d'affichage est optionnel
                return null;
              },
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingM,
              ),
            ),

            // Email (lecture seule)
            KartiaTextField(
              labelText: l10n.email,
              hintText: user.email ?? 'Aucun email',
              prefixIcon: Icons.email_outlined,
              enabled: false,
              suffixWidget: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getEmailStatusColor(user).withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getEmailStatusIcon(user),
                  color: _getEmailStatusColor(user),
                  size: 16,
                ),
              ),
            ),

            if (user.phoneNumber != null) ...[
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),
              KartiaTextField(
                labelText: l10n.phoneNumber,
                hintText: user.phoneNumber!,
                prefixIcon: Icons.phone_outlined,
                enabled: false,
                suffixWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: AppColors.primaryPurple,
                    size: 16,
                  ),
                ),
              ),
            ],

            if (firestoreUser?.username != null) ...[
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),
              KartiaTextField(
                labelText: 'Nom d\'utilisateur',
                hintText: '@${firestoreUser!.username}',
                prefixIcon: Icons.alternate_email,
                enabled: false,
                suffixWidget: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection(KartiaLocalizations l10n, user, bool isLoading) {
    // Ne pas afficher pour les comptes anonymes ou téléphone uniquement
    if (user.isAnonymous || (user.email == null && user.phoneNumber != null)) {
      return const SizedBox.shrink();
    }

    return ProfileSection(
      title: l10n.passwordSection,
      icon: Icons.lock_outline,
      gradient: LinearGradient(colors: [AppColors.warning, AppColors.error]),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Modifier le mot de passe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceColor(context),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color:
                        _isPasswordChangeMode
                            ? AppColors.warning.withAlpha(15)
                            : AppColors.onSurfaceSecondaryColor(
                              context,
                            ).withAlpha(30),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Switch(
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
                    activeColor: AppColors.warning,
                  ),
                ),
              ],
            ),

            if (_isPasswordChangeMode) ...[
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingL,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.warning.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.changePassword,
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getAdaptiveFontSize(
                            context,
                            baseFontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),

              KartiaPasswordField(
                controller: _newPasswordController,
                labelText: l10n.newPassword,
                hintText: l10n.newPasswordHint,
                enabled: !isLoading,
                validator: (value) {
                  if (_isPasswordChangeMode && (value?.isEmpty ?? true)) {
                    return l10n.validationNewPasswordRequired;
                  }
                  if (_isPasswordChangeMode &&
                      !Validators.isValidPassword(value!)) {
                    return l10n.validationPasswordMinLength;
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),

              KartiaPasswordField(
                controller: _confirmPasswordController,
                labelText: l10n.confirmPassword,
                hintText: l10n.confirmPasswordHint,
                enabled: !isLoading,
                validator: (value) {
                  if (_isPasswordChangeMode && (value?.isEmpty ?? true)) {
                    return l10n.validationConfirmPasswordRequired;
                  }
                  if (_isPasswordChangeMode &&
                      !Validators.isValidCPassword(
                        _newPasswordController.text,
                        value!,
                      )) {
                    return l10n.validationPasswordsDoNotMatch;
                  }
                  return null;
                },
              ),
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.recentLoginRequired,
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: ResponsiveUtils.getAdaptiveFontSize(
                            context,
                            baseFontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceSecondaryColor(
                    context,
                  ).withAlpha(30),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.toggle_off,
                      color: AppColors.onSurfaceSecondaryColor(context),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.enableToChange,
                        style: TextStyle(
                          color: AppColors.onSurfaceSecondaryColor(context),
                          fontSize: ResponsiveUtils.getAdaptiveFontSize(
                            context,
                            baseFontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getEmailStatusColor(user) {
    if (user.isAnonymous) return AppColors.warning;
    if (user.phoneNumber != null) return AppColors.primaryPurple;
    if (user.emailVerified) return AppColors.success;
    return AppColors.warning;
  }

  IconData _getEmailStatusIcon(user) {
    if (user.isAnonymous) return Icons.person_outline;
    if (user.phoneNumber != null) return Icons.verified_user;
    if (user.emailVerified) return Icons.verified;
    return Icons.warning;
  }
}
