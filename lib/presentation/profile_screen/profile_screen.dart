import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

// Import your existing services
import 'package:instaappusthb/services/auth_sevice.dart';
import 'package:instaappusthb/services/post_service.dart';
import 'package:instaappusthb/presentation/profile_edit_screen/profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // If null, shows current user's profile
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  // Services
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // State variables
  UserData? _userData;
  List<PostData> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isLoadingPosts = true;
  bool _isUpdatingFollow = false;
  int _selectedTabIndex = 0;

  // UI State
  bool _showAppBar = false;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _setupTabController();
    _setupScrollListener();
    _loadUserData();
    _loadUserPosts();
    if (!_isCurrentUserProfile) {
      _checkFollowStatus();
    }
  }

  void _setupTabController() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _scrollOffset = offset;
        _showAppBar = offset > 150;
      });
    });
  }

  String get _targetUserId {
    if (widget.userId != null) return widget.userId!;
    return _authService.currentUser?.uid ?? '';
  }

  bool get _isCurrentUserProfile {
    if (widget.isCurrentUser) return true;
    return _targetUserId == _authService.currentUser?.uid;
  }

  Future<void> _loadUserData() async {
    try {
      UserData? userData;
      if (_isCurrentUserProfile) {
        userData = await _authService.getCurrentUserData();
      } else {
        userData = await _authService.getUserData(_targetUserId);
      }

      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Erreur lors du chargement du profil');
      }
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      setState(() {
        _isLoadingPosts = true;
      });

      _postService.getUserPostsStream(_targetUserId).listen((posts) {
        if (mounted) {
          setState(() {
            _userPosts = posts;
            _isLoadingPosts = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_isCurrentUserProfile) return;

    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('follows')
          .doc('${currentUserId}_${_targetUserId}')
          .get();

      if (mounted) {
        setState(() {
          _isFollowing = doc.exists;
        });
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (_isUpdatingFollow) return;

    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) {
      _showErrorSnackBar('Vous devez être connecté pour suivre des utilisateurs');
      return;
    }

    setState(() {
      _isUpdatingFollow = true;
    });

    try {
      final followDoc = FirebaseFirestore.instance
          .collection('follows')
          .doc('${currentUserId}_${_targetUserId}');

      final userDoc = FirebaseFirestore.instance.collection('users').doc(_targetUserId);
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);

      if (_isFollowing) {
        // Unfollow
        await followDoc.delete();
        await userDoc.update({'followerCount': FieldValue.increment(-1)});
        await currentUserDoc.update({'followingCount': FieldValue.increment(-1)});

        setState(() {
          _isFollowing = false;
          if (_userData != null) {
            _userData = UserData(
              uid: _userData!.uid,
              email: _userData!.email,
              firstName: _userData!.firstName,
              lastName: _userData!.lastName,
              displayName: _userData!.displayName,
              studentId: _userData!.studentId,
              academicYear: _userData!.academicYear,
              specialty: _userData!.specialty,
              faculty: _userData!.faculty,
              university: _userData!.university,
              profileImageUrl: _userData!.profileImageUrl,
              bio: _userData!.bio,
              isVerified: _userData!.isVerified,
              isActive: _userData!.isActive,
              followerCount: _userData!.followerCount - 1,
              followingCount: _userData!.followingCount,
              postCount: _userData!.postCount,
              createdAt: _userData!.createdAt,
              updatedAt: _userData!.updatedAt,
            );
          }
        });

        _showSuccessSnackBar('Vous ne suivez plus ${_userData?.displayName}');
      } else {
        // Follow
        await followDoc.set({
          'followerId': currentUserId,
          'followingId': _targetUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await userDoc.update({'followerCount': FieldValue.increment(1)});
        await currentUserDoc.update({'followingCount': FieldValue.increment(1)});

        setState(() {
          _isFollowing = true;
          if (_userData != null) {
            _userData = UserData(
              uid: _userData!.uid,
              email: _userData!.email,
              firstName: _userData!.firstName,
              lastName: _userData!.lastName,
              displayName: _userData!.displayName,
              studentId: _userData!.studentId,
              academicYear: _userData!.academicYear,
              specialty: _userData!.specialty,
              faculty: _userData!.faculty,
              university: _userData!.university,
              profileImageUrl: _userData!.profileImageUrl,
              bio: _userData!.bio,
              isVerified: _userData!.isVerified,
              isActive: _userData!.isActive,
              followerCount: _userData!.followerCount + 1,
              followingCount: _userData!.followingCount,
              postCount: _userData!.postCount,
              createdAt: _userData!.createdAt,
              updatedAt: _userData!.updatedAt,
            );
          }
        });

        _showSuccessSnackBar('Vous suivez maintenant ${_userData?.displayName}');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'action');
    }

    setState(() {
      _isUpdatingFollow = false;
    });
  }

  Future<void> _updateProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image == null) return;

      // Show loading dialog
      _showLoadingDialog('Mise à jour de la photo...');

      // Upload to Firebase Storage
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) throw Exception('Utilisateur non connecté');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document
      await _authService.updateCurrentUserData({
        'profileImageUrl': downloadUrl,
      });

      // Update local state
      if (_userData != null) {
        setState(() {
          _userData = UserData(
            uid: _userData!.uid,
            email: _userData!.email,
            firstName: _userData!.firstName,
            lastName: _userData!.lastName,
            displayName: _userData!.displayName,
            studentId: _userData!.studentId,
            academicYear: _userData!.academicYear,
            specialty: _userData!.specialty,
            faculty: _userData!.faculty,
            university: _userData!.university,
            profileImageUrl: downloadUrl,
            bio: _userData!.bio,
            isVerified: _userData!.isVerified,
            isActive: _userData!.isActive,
            followerCount: _userData!.followerCount,
            followingCount: _userData!.followingCount,
            postCount: _userData!.postCount,
            createdAt: _userData!.createdAt,
            updatedAt: _userData!.updatedAt,
          );
        });
      }

      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Photo de profil mise à jour');

    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Erreur lors de la mise à jour de la photo');
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
            Expanded(
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_userData == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
            ];
          },
          body: _buildTabBarView(),
        ),
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
      ),
      body: Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 20.w,
              color: Colors.grey,
            ),
            SizedBox(height: 2.h),
            Text(
              'Profil introuvable',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: _showAppBar ? 1 : 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: _showAppBar
          ? Text(
        _userData?.displayName ?? '',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
        overflow: TextOverflow.ellipsis,
      )
          : null,
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onPressed: _showOptionsMenu,
        ),
      ],
    );
  }

  Widget _buildTabBarView() {
    return Column(
      children: [
        // Profile Header
        _buildProfileHeader(),

        // Tab Bar
        _buildTabBar(),

        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsGrid(),
              _buildTaggedPosts(),
              _buildSavedPosts(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Info Row
          Row(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _isCurrentUserProfile ? _updateProfileImage : null,
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 10.w,
                    backgroundImage: _userData?.profileImageUrl != null
                        ? NetworkImage(_userData!.profileImageUrl!)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: _userData?.profileImageUrl == null
                        ? Icon(
                      Icons.person,
                      size: 10.w,
                      color: Colors.grey[600],
                    )
                        : null,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Stats - Fixed with Flexible
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatColumn('Publications', _userData!.postCount),
                    ),
                    Expanded(
                      child: _buildStatColumn('Abonnés', _userData!.followerCount),
                    ),
                    Expanded(
                      child: _buildStatColumn('Abonnements', _userData!.followingCount),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Name and Verification
          Row(
            children: [
              Expanded(
                child: Text(
                  _userData!.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_userData!.isVerified) ...[
                SizedBox(width: 1.w),
                Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 4.w,
                ),
              ],
            ],
          ),

          SizedBox(height: 1.h),

          // Academic Info
          Text(
            '${_userData!.academicYear} • ${_userData!.specialty}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 0.5.h),

          Text(
            _userData!.university,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // Bio
          if (_userData!.bio.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              _userData!.bio,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],

          SizedBox(height: 3.h),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return GestureDetector(
      onTap: () => _showStatDetails(label),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isCurrentUserProfile) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              'Modifier le profil',
              onPressed: _editProfile,
              isOutlined: true,
            ),
          ),
          SizedBox(width: 2.w),
          SizedBox(
            width: 12.w,
            child: _buildButton(
              '',
              icon: Icons.person_add,
              onPressed: _showDiscoverPeople,
              isOutlined: true,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              _isFollowing ? 'Suivi(e)' : 'Suivre',
              onPressed: _toggleFollow,
              isOutlined: _isFollowing,
              isLoading: _isUpdatingFollow,
            ),
          ),
          SizedBox(width: 2.w),
          SizedBox(
            width: 12.w,
            child: _buildButton(
              '',
              icon: Icons.message,
              onPressed: _sendMessage,
              isOutlined: true,
            ),
          ),
          SizedBox(width: 2.w),
          SizedBox(
            width: 12.w,
            child: _buildButton(
              '',
              icon: Icons.person_add,
              onPressed: _suggestToFriends,
              isOutlined: true,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButton(
      String text, {
        VoidCallback? onPressed,
        IconData? icon,
        bool isOutlined = false,
        bool isLoading = false,
      }) {
    return SizedBox(
      height: 7.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : Colors.blue,
          foregroundColor: isOutlined ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isOutlined
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
        ),
        child: isLoading
            ? SizedBox(
          width: 4.w,
          height: 4.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isOutlined ? Colors.blue : Colors.white,
          ),
        )
            : icon != null
            ? Icon(icon, size: 5.w)
            : Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(
            icon: Icon(
              _selectedTabIndex == 0 ? Icons.grid_on : Icons.grid_on_outlined,
              size: 6.w,
            ),
          ),
          Tab(
            icon: Icon(
              _selectedTabIndex == 1 ? Icons.person : Icons.person_outline,
              size: 6.w,
            ),
          ),
          Tab(
            icon: Icon(
              _selectedTabIndex == 2 ? Icons.bookmark : Icons.bookmark_border,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_isLoadingPosts) {
      return _buildLoadingGrid();
    }

    if (_userPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.camera_alt,
        title: _isCurrentUserProfile
            ? 'Partagez des photos'
            : 'Aucune publication',
        subtitle: _isCurrentUserProfile
            ? 'Lorsque vous partagerez des photos, elles apparaîtront sur votre profil.'
            : 'Aucune publication partagée pour le moment.',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () => _viewPost(post),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 8.w,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaggedPosts() {
    return _buildEmptyState(
      icon: Icons.person_pin,
      title: 'Photos et vidéos de vous',
      subtitle: 'Lorsque quelqu\'un vous identifiera dans une photo ou une vidéo, elle apparaîtra ici.',
    );
  }

  Widget _buildSavedPosts() {
    if (!_isCurrentUserProfile) {
      return Container(); // Other users can't see saved posts
    }

    return _buildEmptyState(
      icon: Icons.bookmark,
      title: 'Enregistrer',
      subtitle: 'Enregistrez les photos et vidéos que vous voulez revoir. Personne d\'autre ne peut voir ce que vous enregistrez.',
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(1),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[200],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 10.w,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            if (_isCurrentUserProfile && icon == Icons.camera_alt) ...[
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () {
                  // Navigate to create post screen
                  _showErrorSnackBar('Création de post - Fonctionnalité bientôt disponible');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Partager votre première photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Action methods
  void _showStatDetails(String statType) {
    // Show followers/following list
    _showErrorSnackBar('$statType - Fonctionnalité bientôt disponible');
  }

  void _editProfile() {
    // Navigate to edit profile screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
      ),
    ).then((result) {
      // If profile was updated, refresh user data
      if (result == true) {
        _loadUserData();
      }
    });
  }

  void _showDiscoverPeople() {
    // Navigate to discover people screen
    _showErrorSnackBar('Découvrir des personnes - Fonctionnalité bientôt disponible');
  }

  void _sendMessage() {
    // Navigate to chat screen
    _showErrorSnackBar('Messages - Fonctionnalité bientôt disponible');
  }

  void _suggestToFriends() {
    // Show suggestion dialog
    _showErrorSnackBar('Suggestion à des amis - Fonctionnalité bientôt disponible');
  }

  void _viewPost(PostData post) {
    // Navigate to post detail screen
    _showErrorSnackBar('Voir le post - Fonctionnalité bientôt disponible');
  }

  void _showOptionsMenu() {
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
            if (_isCurrentUserProfile) ...[
              _buildMenuOption(
                icon: Icons.qr_code,
                title: 'Code QR',
                onTap: () {
                  Navigator.pop(context);
                  _showQRCode();
                },
              ),
              _buildMenuOption(
                icon: Icons.archive,
                title: 'Archive',
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('Archive - Fonctionnalité bientôt disponible');
                },
              ),
              _buildMenuOption(
                icon: Icons.history,
                title: 'Votre activité',
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('Activité - Fonctionnalité bientôt disponible');
                },
              ),
              _buildMenuOption(
                icon: Icons.settings,
                title: 'Paramètres et confidentialité',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSettings();
                },
              ),
            ] else ...[
              _buildMenuOption(
                icon: Icons.copy,
                title: 'Copier le profil',
                onTap: () {
                  Navigator.pop(context);
                  _copyProfileUrl();
                },
              ),
              _buildMenuOption(
                icon: Icons.share,
                title: 'Partager ce profil',
                onTap: () {
                  Navigator.pop(context);
                  _shareProfile();
                },
              ),
              _buildMenuOption(
                icon: Icons.block,
                title: 'Bloquer',
                onTap: () {
                  Navigator.pop(context);
                  _showBlockUserDialog();
                },
                isDestructive: true,
              ),
              _buildMenuOption(
                icon: Icons.report,
                title: 'Signaler',
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
                isDestructive: true,
              ),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontSize: 16.sp,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Code QR'),
        content: Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  size: 20.w,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Code QR du profil',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _copyProfileUrl() {
    Clipboard.setData(ClipboardData(
      text: 'https://instaustb.com/profile/${_userData!.uid}',
    ));
    _showSuccessSnackBar('Lien du profil copié');
  }

  void _shareProfile() {
    Share.share(
      'Consultez le profil de ${_userData!.displayName} sur InstaUSTHB\nhttps://instaustb.com/profile/${_userData!.uid}',
      subject: 'Profil InstaUSTHB',
    );
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bloquer ${_userData!.displayName} ?'),
        content: Text(
          'Cette personne ne pourra plus vous trouver ou voir votre profil, vos publications ou votre story sur InstaUSTHB. Elle ne sera pas informée que vous l\'avez bloquée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser();
            },
            child: Text(
              'Bloquer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Signaler ce compte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pourquoi signalez-vous ce compte ?'),
            SizedBox(height: 2.h),
            // Report options
            ListTile(
              title: Text('Contenu inapproprié'),
              onTap: () {
                Navigator.pop(context);
                _reportUser('inappropriate_content');
              },
            ),
            ListTile(
              title: Text('Spam'),
              onTap: () {
                Navigator.pop(context);
                _reportUser('spam');
              },
            ),
            ListTile(
              title: Text('Harcèlement'),
              onTap: () {
                Navigator.pop(context);
                _reportUser('harassment');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _blockUser() async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return;

      await FirebaseFirestore.instance
          .collection('blocks')
          .doc('${currentUserId}_${_targetUserId}')
          .set({
        'blockerId': currentUserId,
        'blockedId': _targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Utilisateur bloqué');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Erreur lors du blocage');
    }
  }

  void _reportUser(String reason) async {
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return;

      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': currentUserId,
        'reportedId': _targetUserId,
        'reason': reason,
        'type': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Signalement envoyé');
    } catch (e) {
      _showErrorSnackBar('Erreur lors du signalement');
    }
  }

  void _navigateToSettings() {
    // Navigate to settings screen
    _showErrorSnackBar('Paramètres - Fonctionnalité bientôt disponible');
  }
}