import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kartia/generated/l10n.dart';
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
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _staggerAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Animations échelonnées pour les sections
  late Animation<Offset> _avatarSlideAnimation;
  late Animation<Offset> _personalSlideAnimation;
  late Animation<Offset> _passwordSlideAnimation;

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

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Animations échelonnées
    _avatarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _personalSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimations() {
    _fadeAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scaleAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _staggerAnimationController.forward();
    });
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
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _staggerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = KartiaLocalizations.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo_camera, color: AppColors.white),
                      SizedBox(width: 12),
                      Text(
                        l10n.choosePhoto,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildImagePickerOption(
                          l10n,
                          icon: Icons.camera_alt,
                          label: l10n.camera,
                          onTap: () => _selectImage(ImageSource.camera),
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                        ),
                      ),
                      SizedBox(width: widthSpace.width!),
                      Expanded(
                        child: _buildImagePickerOption(
                          l10n,
                          icon: Icons.photo_library,
                          label: l10n.gallery,
                          onTap: () => _selectImage(ImageSource.gallery),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryPurple,
                              AppColors.primary,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_selectedImage != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                      right: 20,
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
              ],
            ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
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
            Icon(icon, color: AppColors.white, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
        setState(() {
          _selectedImage = File(image.path);
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      KartiaSnackbar.show(
        // ignore: use_build_context_synchronously
        context,
        message: l10n.errorImageSelection(e.toString()),
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
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.discardChanges),
          ),
        ],
      );
    } else {
      context.pop();
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
                AppColors.secondary.withAlpha(5),
                Colors.white,
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
                        context.pop();
                      }
                    },
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(fixPadding),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final user = state.user;
                              final isLoading = state.isLoading;

                              if (user == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                    SlideTransition(
                                      position: _avatarSlideAnimation,
                                      child: ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: _buildProfilePictureSection(
                                          l10n,
                                          user,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: heightSpace.height! * 2),
                                    SlideTransition(
                                      position: _personalSlideAnimation,
                                      child: _buildPersonalInfoSection(
                                        l10n,
                                        user,
                                        isLoading,
                                      ),
                                    ),
                                    SizedBox(height: heightSpace.height! * 2),
                                    SlideTransition(
                                      position: _passwordSlideAnimation,
                                      child: _buildPasswordSection(
                                        l10n,
                                        user,
                                        isLoading,
                                      ),
                                    ),
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
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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

  Widget _buildProfilePictureSection(KartiaLocalizations l10n, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow2,
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.photo_camera,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                l10n.profilePicture,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: heightSpace.height! * 1.5),

          // Avatar avec option de modification
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: AppColors.white,
                  child: CircleAvatar(
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
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                            : null,
                  ),
                ),
              ),

              // Bouton de modification avec animation
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
                        colors: [AppColors.secondary, AppColors.primaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.white, width: 3),
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
                      Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: heightSpace.height!),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.mediumGrey, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.changePhoto,
                    style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    KartiaLocalizations l10n,
    user,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow2,
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                l10n.personalInformation,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: heightSpace.height! * 1.5),

          // Nom d'affichage
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
          SizedBox(height: heightSpace.height!),

          // Email (lecture seule)
          KartiaTextField(
            labelText: l10n.email,
            hintText: user.email ?? 'Aucun email',
            prefixIcon: Icons.email_outlined,
            enabled: false,
            suffixWidget: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    user.emailVerified
                        ? AppColors.success.withAlpha(15)
                        : AppColors.warning.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                user.emailVerified ? Icons.verified : Icons.warning,
                color:
                    user.emailVerified ? AppColors.success : AppColors.warning,
                size: 16,
              ),
            ),
          ),

          if (user.phoneNumber != null) ...[
            SizedBox(height: heightSpace.height!),
            // Téléphone (lecture seule)
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
        ],
      ),
    );
  }

  Widget _buildPasswordSection(KartiaLocalizations l10n, user, bool isLoading) {
    // Ne pas afficher la section mot de passe pour les comptes anonymes ou Google
    if (user.isAnonymous || user.email == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _isPasswordChangeMode
                  ? AppColors.warning.withAlpha(30)
                  : AppColors.lightGrey.withAlpha(50),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _isPasswordChangeMode
                    ? AppColors.warning.withAlpha(10)
                    : AppColors.shadow2,
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.warning, AppColors.error],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    l10n.passwordSection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      _isPasswordChangeMode
                          ? AppColors.warning.withAlpha(15)
                          : AppColors.lightGrey.withAlpha(30),
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
            SizedBox(height: heightSpace.height! * 1.5),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: AppColors.warning, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.changePassword,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: heightSpace.height!),

            // Nouveau mot de passe
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
            SizedBox(height: heightSpace.height!),

            // Confirmer le nouveau mot de passe
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
            SizedBox(height: heightSpace.height!),

            // Note informative
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.recentLoginRequired,
                      style: TextStyle(color: AppColors.info, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: heightSpace.height!),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.toggle_off, color: AppColors.mediumGrey, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.enableToChange,
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
