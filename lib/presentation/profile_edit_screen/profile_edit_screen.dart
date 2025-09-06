import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import your existing services
import 'package:instaappusthb/services/auth_sevice.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Services
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  // State variables
  UserData? _userData;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _selectedAcademicYear;
  String? _selectedSpecialty;
  File? _newProfileImage;
  String? _profileImageUrl;

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _firstNameError;
  String? _lastNameError;
  String? _bioError;
  String? _emailError;
  String? _studentIdError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null && mounted) {
        setState(() {
          _userData = userData;
          _firstNameController.text = userData.firstName;
          _lastNameController.text = userData.lastName;
          _bioController.text = userData.bio;
          _emailController.text = userData.email;
          _studentIdController.text = userData.studentId;
          _selectedAcademicYear = userData.academicYear;
          _selectedSpecialty = userData.specialty;
          _profileImageUrl = userData.profileImageUrl;
          _isLoading = false;
        });

        // Listen to text changes
        _setupTextListeners();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Erreur lors du chargement des données');
      }
    }
  }

  void _setupTextListeners() {
    _firstNameController.addListener(_onTextChanged);
    _lastNameController.addListener(_onTextChanged);
    _bioController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _studentIdController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
    _validateFields();
  }

  void _onDropdownChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  void _validateFields() {
    setState(() {
      _firstNameError = _validateName(_firstNameController.text, 'Prénom');
      _lastNameError = _validateName(_lastNameController.text, 'Nom');
      _bioError = _validateBio(_bioController.text);
      _emailError = _validateEmail(_emailController.text);
      _studentIdError = _validateStudentId(_studentIdController.text);
    });
  }

  String? _validateName(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName requis';
    if (value.trim().length < 2) return '$fieldName trop court (min. 2 caractères)';
    if (value.trim().length > 30) return '$fieldName trop long (max. 30 caractères)';
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return '$fieldName ne doit contenir que des lettres';
    }
    return null;
  }

  String? _validateBio(String value) {
    if (value.length > 150) return 'Bio trop longue (max. 150 caractères)';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email requis';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validateStudentId(String value) {
    if (value.trim().isEmpty) return 'Numéro d\'étudiant requis';
    if (!RegExp(r'^\d{12}$').hasMatch(value.trim())) {
      return 'Format invalide (12 chiffres requis)';
    }
    return null;
  }

  bool get _isFormValid {
    return _firstNameError == null &&
        _lastNameError == null &&
        _bioError == null &&
        _emailError == null &&
        _studentIdError == null &&
        _selectedAcademicYear != null &&
        _selectedSpecialty != null;
  }

  Future<void> _pickProfileImage() async {
    try {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Changer la photo de profil',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              // FIXED: Wrap with SingleChildScrollView and use flexible layout
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Appareil photo',
                      source: ImageSource.camera,
                    ),
                    SizedBox(width: 4.w),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galerie',
                      source: ImageSource.gallery,
                    ),
                    if (_profileImageUrl != null || _newProfileImage != null) ...[
                      SizedBox(width: 4.w),
                      _buildImageSourceOption(
                        icon: Icons.delete,
                        label: 'Supprimer',
                        onTap: _removeProfileImage,
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection de la photo');
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    ImageSource? source,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap();
        } else if (source != null) {
          _selectImageFromSource(source);
        }
      },
      child: Container(
        // FIXED: Add constraints to prevent overflow
        constraints: BoxConstraints(
          minWidth: 20.w,
          maxWidth: 25.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey[100],
              ),
              child: Icon(
                icon,
                size: 6.w,
                color: isDestructive ? Colors.red : Colors.grey[700],
              ),
            ),
            SizedBox(height: 1.h),
            // FIXED: Add flexible text with overflow handling
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDestructive ? Colors.red : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _newProfileImage = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection de l\'image');
    }
  }

  void _removeProfileImage() {
    setState(() {
      _newProfileImage = null;
      _profileImageUrl = null;
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_isFormValid) {
      _showErrorSnackBar('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      Map<String, dynamic> updateData = {};

      // Check and update basic info
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      if (firstName != _userData!.firstName) {
        updateData['firstName'] = firstName;
      }

      if (lastName != _userData!.lastName) {
        updateData['lastName'] = lastName;
      }

      if (firstName != _userData!.firstName || lastName != _userData!.lastName) {
        updateData['displayName'] = '$firstName $lastName';
      }

      if (_bioController.text != _userData!.bio) {
        updateData['bio'] = _bioController.text.trim();
      }

      if (_emailController.text.trim() != _userData!.email) {
        // Email change requires special handling
        await _updateEmail(_emailController.text.trim());
        updateData['email'] = _emailController.text.trim();
      }

      if (_studentIdController.text.trim() != _userData!.studentId) {
        // Check if new student ID is available
        final isStudentIdTaken = await _authService.isStudentIdTaken(_studentIdController.text.trim());
        if (isStudentIdTaken) {
          _showErrorSnackBar('Ce numéro d\'étudiant est déjà utilisé');
          setState(() {
            _isSaving = false;
          });
          return;
        }
        updateData['studentId'] = _studentIdController.text.trim();
      }

      if (_selectedAcademicYear != _userData!.academicYear) {
        updateData['academicYear'] = _selectedAcademicYear!;
      }

      if (_selectedSpecialty != _userData!.specialty) {
        updateData['specialty'] = _selectedSpecialty!;
      }

      // Handle profile image
      if (_newProfileImage != null) {
        _showLoadingDialog('Téléchargement de la photo...');
        final imageUrl = await _uploadProfileImage(_newProfileImage!);
        Navigator.pop(context); // Close loading dialog

        if (imageUrl != null) {
          updateData['profileImageUrl'] = imageUrl;
          _profileImageUrl = imageUrl;
        }
      } else if (_profileImageUrl == null && _userData!.profileImageUrl != null) {
        // User removed profile image
        updateData['profileImageUrl'] = null;
      }

      // Update user data
      if (updateData.isNotEmpty) {
        final success = await _authService.updateCurrentUserData(updateData);

        if (success) {
          // Update display name in Firebase Auth if name changed
          if (updateData.containsKey('displayName')) {
            await _authService.currentUser?.updateDisplayName(updateData['displayName']);
          }

          _showSuccessSnackBar('Profil mis à jour avec succès');
          setState(() {
            _hasChanges = false;
          });
          Navigator.pop(context, true); // Return true to indicate changes were made
        } else {
          _showErrorSnackBar('Erreur lors de la mise à jour du profil');
        }
      } else {
        Navigator.pop(context, false);
      }

    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sauvegarde: ${e.toString()}');
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _updateEmail(String newEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // CORRECTED: Use verifyBeforeUpdateEmail instead of updateEmail
      await user.verifyBeforeUpdateEmail(newEmail);

      _showSuccessSnackBar('Un email de vérification a été envoyé à votre nouvelle adresse. Veuillez le confirmer pour finaliser le changement.');
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String errorMessage;
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Veuillez vous reconnecter avant de changer votre email';
          break;
        case 'email-already-in-use':
          errorMessage = 'Cette adresse email est déjà utilisée';
          break;
        case 'invalid-email':
          errorMessage = 'Format d\'email invalide';
          break;
        default:
          errorMessage = 'Erreur lors de la mise à jour de l\'email';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'email: ${e.toString()}');
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(width: 4.w),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges && !_isSaving) {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Modifications non sauvegardées'),
          content: Text('Voulez-vous sauvegarder vos modifications avant de quitter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Quitter sans sauvegarder',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                _saveProfile();
              },
              child: Text('Sauvegarder'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Colors.black),
        onPressed: () async {
          final canPop = await _onWillPop();
          if (canPop) Navigator.pop(context);
        },
      ),
      title: Text(
        'Modifier le profil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving || !_hasChanges || !_isFormValid ? null : _saveProfile,
          child: _isSaving
              ? SizedBox(
            width: 4.w,
            height: 4.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          )
              : Text(
            'Terminé',
            style: TextStyle(
              color: _hasChanges && _isFormValid ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfileImageSection(),
            SizedBox(height: 4.h),
            _buildPersonalInfoSection(),
            SizedBox(height: 3.h),
            _buildAcademicInfoSection(),
            SizedBox(height: 3.h),
            _buildBioSection(),
            SizedBox(height: 6.h),
            _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Stack(
            children: [
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: CircleAvatar(
                  radius: 12.w,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : (_profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null) as ImageProvider?,
                  backgroundColor: Colors.grey[200],
                  child: (_newProfileImage == null && _profileImageUrl == null)
                      ? Icon(
                    Icons.person,
                    size: 12.w,
                    color: Colors.grey[600],
                  )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Changer la photo de profil',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informations personnelles'),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _firstNameController,
          label: 'Prénom',
          errorText: _firstNameError,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
            LengthLimitingTextInputFormatter(30),
          ],
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _lastNameController,
          label: 'Nom',
          errorText: _lastNameError,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
            LengthLimitingTextInputFormatter(30),
          ],
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _studentIdController,
          label: 'Numéro d\'étudiant',
          errorText: _studentIdError,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informations académiques'),
        SizedBox(height: 2.h),
        _buildDropdownField(
          value: _selectedAcademicYear,
          label: 'Année académique',
          items: AuthService.academicYears,
          onChanged: (value) {
            setState(() {
              _selectedAcademicYear = value;
            });
            _onDropdownChanged();
          },
        ),
        SizedBox(height: 2.h),
        _buildDropdownField(
          value: _selectedSpecialty,
          label: 'Spécialité',
          items: AuthService.specialties,
          onChanged: (value) {
            setState(() {
              _selectedSpecialty = value;
            });
            _onDropdownChanged();
          },
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Biographie'),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          errorText: _bioError,
          maxLines: 3,
          maxLength: 150,
          hint: 'Parlez-nous de vous...',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    String? hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4.w),
              counterText: maxLength != null ? null : '',
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            errorText,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: TextButton(
        onPressed: _showDeleteAccountDialog,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: Text(
          'Supprimer le compte',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le compte'),
        content: Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées.\n\nÊtes-vous sûr de vouloir supprimer votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      _showLoadingDialog('Suppression du compte...');

      final result = await _authService.deleteCurrentUserAccount();

      Navigator.pop(context); // Close loading dialog

      if (result.success) {
        // Navigate to login screen and clear all routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'Erreur lors de la suppression du compte');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Erreur lors de la suppression du compte');
    }
  }
}