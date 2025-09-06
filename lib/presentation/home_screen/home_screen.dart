import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaappusthb/core/app_export.dart';
import 'package:instaappusthb/services/auth_sevice.dart';
import 'package:instaappusthb/services/post_service.dart';
import 'package:instaappusthb/presentation/profile_screen/profile_screen.dart';
import 'package:flutter/rendering.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // Controllers and Animation
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  // Services
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final StoryService _storyService = StoryService();

  // State variables
  UserData? _currentUser;
  bool _isLoading = true;
  bool _showFab = true;
  int _selectedBottomIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCurrentUser();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 2, vsync: this);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showFab) {
          setState(() {
            _showFab = false;
          });
          _fabAnimationController.reverse();
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
          });
          _fabAnimationController.forward();
        }
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUserData();
      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement du profil');
    }
  }

  Future<void> _onRefresh() async {
    await _loadCurrentUser();
    _refreshController.refreshCompleted();
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

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedBottomIndex,
            children: [
              // Home Feed
              _buildHomeFeed(),
              // Search Screen
              _buildSearchScreen(),
              // Create Post Screen
              _buildCreatePostScreen(),
              // Activity Screen
              _buildActivityScreen(),
              // Profile Screen - Use the ProfileScreen widget
              ProfileScreen(
                userId: _currentUser?.uid,
                isCurrentUser: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedBottomIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
            SizedBox(height: 2.h),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFeed() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Custom App Bar
        _buildSliverAppBar(),

        // Stories Section
        SliverToBoxAdapter(
          child: _buildStoriesSection(),
        ),

        // Posts Feed
        _buildPostsSection(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            // Logo
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // App Title
            Text(
              'InstaUSTHB',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.blue,
                letterSpacing: -0.5,
                fontSize: 20.sp,
              ),
            ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.favorite_border_rounded,
                  onTap: () => setState(() => _selectedBottomIndex = 3),
                ),
                SizedBox(width: 2.w),
                _buildIconButton(
                  icon: Icons.send_rounded,
                  onTap: () => _showDirectMessages(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 5.w,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 12.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: StreamBuilder<List<StoryData>>(
        stream: _storyService.getStoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildStoriesLoading();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyStories();
          }

          final stories = snapshot.data!;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: stories.length + 1, // +1 for "Add Story" button
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddStoryButton();
              }

              final story = stories[index - 1];
              return _buildStoryItem(story);
            },
          );
        },
      ),
    );
  }

  Widget _buildStoriesLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 18.w,
          margin: EdgeInsets.only(right: 3.w),
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                width: 12.w,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStories() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAddStoryButton(),
        ],
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Container(
      width: 18.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: _createNewStory,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.purple,
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Votre story',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(StoryData story) {
    return Container(
      width: 18.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _viewStory(story),
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFFFE66D),
                    Color(0xFF4ECDC4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(0.5.w),
                child: CircleAvatar(
                  backgroundImage: story.userProfileImageUrl != null
                      ? NetworkImage(story.userProfileImageUrl!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: story.userProfileImageUrl == null
                      ? Icon(
                    Icons.person_rounded,
                    color: Colors.grey[600],
                    size: 6.w,
                  )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            story.userName.split(' ').first,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return StreamBuilder<List<PostData>>(
            stream: _postService.getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildPostsLoading();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyPosts();
              }

              final posts = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, postIndex) {
                  final post = posts[postIndex];
                  return _buildPostItem(post);
                },
              );
            },
          );
        },
        childCount: 1,
      ),
    );
  }

  Widget _buildPostsLoading() {
    return Column(
      children: List.generate(3, (index) => _buildPostLoadingSkeleton()),
    );
  }

  Widget _buildPostLoadingSkeleton() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(vertical: 2.h),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      width: 20.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Image skeleton
          Container(
            width: double.infinity,
            height: 50.h,
            color: Colors.grey.shade300,
          ),

          SizedBox(height: 2.h),

          // Action buttons skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPosts() {
    return Container(
      height: 40.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_rounded,
              size: 15.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              'Aucun post pour le moment',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Commencez à suivre des personnes pour voir leurs publications',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => setState(() => _selectedBottomIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Découvrir des personnes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(PostData post) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          _buildPostHeader(post),

          // Post Image
          if (post.imageUrl.isNotEmpty)
            _buildPostImage(post),

          // Post Actions
          _buildPostActions(post),

          // Post Info
          _buildPostInfo(post),

          // Comments Preview
          _buildCommentsPreview(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(PostData post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () => _viewProfile(post.userId),
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: post.userProfileImageUrl != null
                    ? NetworkImage(post.userProfileImageUrl!)
                    : null,
                backgroundColor: Colors.grey[200],
                child: post.userProfileImageUrl == null
                    ? Icon(
                  Icons.person_rounded,
                  color: Colors.grey[600],
                  size: 5.w,
                )
                    : null,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (post.userIsVerified) ...[
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.blue,
                        size: 4.w,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${post.userAcademicYear} • ${post.userSpecialty}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          // More Options
          GestureDetector(
            onTap: () => _showPostOptions(post),
            child: Icon(
              Icons.more_vert_rounded,
              color: Colors.grey.shade600,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(PostData post) {
    return GestureDetector(
      onDoubleTap: () => _toggleLike(post),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: 60.h,
          minHeight: 30.h,
        ),
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 40.h,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 40.h,
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey.shade400,
                      size: 10.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Impossible de charger l\'image',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostActions(PostData post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          // Like Button
          GestureDetector(
            onTap: () => _toggleLike(post),
            child: Icon(
              post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: post.isLiked ? Colors.red : Colors.grey.shade700,
              size: 7.w,
            ),
          ),

          SizedBox(width: 4.w),

          // Comment Button
          GestureDetector(
            onTap: () => _showComments(post),
            child: Icon(
              Icons.mode_comment_outlined,
              color: Colors.grey.shade700,
              size: 7.w,
            ),
          ),

          SizedBox(width: 4.w),

          // Share Button
          GestureDetector(
            onTap: () => _sharePost(post),
            child: Icon(
              Icons.send_rounded,
              color: Colors.grey.shade700,
              size: 7.w,
            ),
          ),

          const Spacer(),

          // Save Button
          GestureDetector(
            onTap: () => _toggleSave(post),
            child: Icon(
              post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: post.isSaved ? Colors.black : Colors.grey.shade700,
              size: 7.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(PostData post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes Count
          if (post.likesCount > 0)
            GestureDetector(
              onTap: () => _showLikes(post),
              child: Text(
                '${post.likesCount} j\'aime${post.likesCount > 1 ? 's' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),

          if (post.likesCount > 0)
            SizedBox(height: 0.5.h),

          // Caption
          if (post.caption.isNotEmpty)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.userName} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                  TextSpan(
                    text: post.caption,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

          if (post.caption.isNotEmpty)
            SizedBox(height: 1.h),

          // Time ago
          Text(
            _getTimeAgo(post.createdAt),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsPreview(PostData post) {
    if (post.commentsCount == 0) {
      return SizedBox(height: 2.h);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: GestureDetector(
        onTap: () => _showComments(post),
        child: Text(
          'Voir les ${post.commentsCount} commentaire${post.commentsCount > 1 ? 's' : ''}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                isActive: _selectedBottomIndex == 0,
                onTap: () => setState(() => _selectedBottomIndex = 0),
              ),
              _buildBottomNavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                isActive: _selectedBottomIndex == 1,
                onTap: () => setState(() => _selectedBottomIndex = 1),
              ),
              _buildBottomNavItem(
                icon: Icons.add_box_outlined,
                activeIcon: Icons.add_box_rounded,
                isActive: _selectedBottomIndex == 2,
                onTap: () => setState(() => _selectedBottomIndex = 2),
              ),
              _buildBottomNavItem(
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                isActive: _selectedBottomIndex == 3,
                onTap: () => setState(() => _selectedBottomIndex = 3),
              ),
              _buildBottomNavItem(
                icon: Icons.account_circle_outlined,
                activeIcon: Icons.account_circle_rounded,
                isActive: _selectedBottomIndex == 4,
                onTap: () => setState(() => _selectedBottomIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        child: Icon(
          isActive ? activeIcon : icon,
          size: 7.w,
          color: isActive ? Colors.blue : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: () => setState(() => _selectedBottomIndex = 2),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 8.w,
        ),
      ),
    );
  }

  Widget _buildSearchScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 15.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            'Recherche',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Fonctionnalité bientôt disponible',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 15.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            'Créer un post',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Fonctionnalité bientôt disponible',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 15.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            'Activité',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Fonctionnalité bientôt disponible',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Action methods
  void _showDirectMessages() {
    _showErrorSnackBar('Messages directs - Fonctionnalité bientôt disponible');
  }

  void _createNewStory() {
    _showErrorSnackBar('Création de story - Fonctionnalité bientôt disponible');
  }

  void _viewStory(StoryData story) {
    _showErrorSnackBar('Visualisation de story - Fonctionnalité bientôt disponible');
  }

  void _viewProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: userId,
          isCurrentUser: userId == _currentUser?.uid,
        ),
      ),
    );
  }

  void _showPostOptions(PostData post) {
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
            ListTile(
              leading: Icon(Icons.share_rounded),
              title: Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                _sharePost(post);
              },
            ),
            ListTile(
              leading: Icon(Icons.link_rounded),
              title: Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                _showSuccessSnackBar('Lien copié');
              },
            ),
            if (post.userId == _currentUser?.uid) ...[
              ListTile(
                leading: Icon(Icons.edit_rounded),
                title: Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('Modification - Fonctionnalité bientôt disponible');
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: Colors.red),
                title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('Suppression - Fonctionnalité bientôt disponible');
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.report_rounded, color: Colors.red),
                title: Text('Signaler', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showErrorSnackBar('Signalement - Fonctionnalité bientôt disponible');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleLike(PostData post) {
    _postService.toggleLike(post.id).then((result) {
      if (result.success) {
        // The stream will automatically update the UI
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'Erreur lors du like');
      }
    });
  }

  void _showComments(PostData post) {
    _showErrorSnackBar('Commentaires - Fonctionnalité bientôt disponible');
  }

  void _sharePost(PostData post) {
    _showErrorSnackBar('Partage - Fonctionnalité bientôt disponible');
  }

  void _toggleSave(PostData post) {
    _postService.toggleSave(post.id).then((result) {
      if (result.success) {
        // The stream will automatically update the UI
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'Erreur lors de la sauvegarde');
      }
    });
  }

  void _showLikes(PostData post) {
    _showErrorSnackBar('Liste des likes - Fonctionnalité bientôt disponible');
  }
}