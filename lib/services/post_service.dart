// post_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaappusthb/services/auth_sevice.dart'; // Import UserData from auth_service
import 'dart:io';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String postsCollection = 'posts';
  static const String likesCollection = 'likes';
  static const String commentsCollection = 'comments';
  static const String savedPostsCollection = 'saved_posts';

  /// Get posts stream for home feed
  Stream<List<PostData>> getPostsStream() {
    try {
      return _firestore
          .collection(postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .asyncMap((snapshot) async {
        List<PostData> posts = [];

        for (var doc in snapshot.docs) {
          if (doc.exists && doc.data().isNotEmpty) {
            try {
              final postData = await _enrichPostData(doc);
              if (postData != null) {
                posts.add(postData);
              }
            } catch (e) {
              debugPrint('Error processing post ${doc.id}: $e');
            }
          }
        }

        return posts;
      });
    } catch (e) {
      debugPrint('Error getting posts stream: $e');
      return Stream.value([]);
    }
  }

  /// Get posts for specific user
  Stream<List<PostData>> getUserPostsStream(String userId) {
    try {
      return _firestore
          .collection(postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<PostData> posts = [];

        for (var doc in snapshot.docs) {
          if (doc.exists && doc.data().isNotEmpty) {
            try {
              final postData = await _enrichPostData(doc);
              if (postData != null) {
                posts.add(postData);
              }
            } catch (e) {
              debugPrint('Error processing user post ${doc.id}: $e');
            }
          }
        }

        return posts;
      });
    } catch (e) {
      debugPrint('Error getting user posts stream: $e');
      return Stream.value([]);
    }
  }

  /// Create a new post
  Future<PostResult> createPost({
    required String caption,
    required File imageFile,
    String? location,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return PostResult.failure('Utilisateur non connecté');
      }

      // Upload image to Firebase Storage
      final imageUploadResult = await _uploadImage(imageFile);
      if (!imageUploadResult.success) {
        return PostResult.failure(imageUploadResult.errorMessage ?? 'Erreur lors du téléchargement de l\'image');
      }

      // Get user data
      final userData = await _getUserData(currentUser.uid);
      if (userData == null) {
        return PostResult.failure('Données utilisateur non trouvées');
      }

      // Create post document
      final postRef = _firestore.collection(postsCollection).doc();
      final postData = {
        'id': postRef.id,
        'userId': currentUser.uid,
        'userName': userData.displayName,
        'userAcademicYear': userData.academicYear,
        'userSpecialty': userData.specialty,
        'userProfileImageUrl': userData.profileImageUrl,
        'userIsVerified': userData.isVerified,
        'imageUrl': imageUploadResult.imageUrl,
        'caption': caption.trim(),
        'location': location?.trim(),
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await postRef.set(postData);

      // Update user's post count
      await _firestore.collection('users').doc(currentUser.uid).update({
        'postCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return PostResult.success(postRef.id);

    } catch (e) {
      debugPrint('Error creating post: $e');
      return PostResult.failure('Erreur lors de la création du post');
    }
  }

  /// Toggle like on a post
  Future<LikeResult> toggleLike(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return LikeResult.failure('Utilisateur non connecté');
      }

      final likeRef = _firestore
          .collection(likesCollection)
          .doc('${postId}_${currentUser.uid}');

      final likeDoc = await likeRef.get();
      final postRef = _firestore.collection(postsCollection).doc(postId);

      if (likeDoc.exists) {
        // Unlike the post
        await likeRef.delete();
        await postRef.update({
          'likesCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return LikeResult.success(false);
      } else {
        // Like the post
        await likeRef.set({
          'postId': postId,
          'userId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likesCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return LikeResult.success(true);
      }

    } catch (e) {
      debugPrint('Error toggling like: $e');
      return LikeResult.failure('Erreur lors du like');
    }
  }

  /// Toggle save on a post
  Future<SaveResult> toggleSave(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return SaveResult.failure('Utilisateur non connecté');
      }

      final saveRef = _firestore
          .collection(savedPostsCollection)
          .doc('${currentUser.uid}_${postId}');

      final saveDoc = await saveRef.get();

      if (saveDoc.exists) {
        // Unsave the post
        await saveRef.delete();
        return SaveResult.success(false);
      } else {
        // Save the post
        await saveRef.set({
          'userId': currentUser.uid,
          'postId': postId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return SaveResult.success(true);
      }

    } catch (e) {
      debugPrint('Error toggling save: $e');
      return SaveResult.failure('Erreur lors de la sauvegarde');
    }
  }

  /// Add comment to a post
  Future<CommentResult> addComment(String postId, String comment) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return CommentResult.failure('Utilisateur non connecté');
      }

      if (comment.trim().isEmpty) {
        return CommentResult.failure('Le commentaire ne peut pas être vide');
      }

      // Get user data
      final userData = await _getUserData(currentUser.uid);
      if (userData == null) {
        return CommentResult.failure('Données utilisateur non trouvées');
      }

      // Create comment document
      final commentRef = _firestore.collection(commentsCollection).doc();
      await commentRef.set({
        'id': commentRef.id,
        'postId': postId,
        'userId': currentUser.uid,
        'userName': userData.displayName,
        'userProfileImageUrl': userData.profileImageUrl,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update post's comment count
      await _firestore.collection(postsCollection).doc(postId).update({
        'commentsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return CommentResult.success(commentRef.id);

    } catch (e) {
      debugPrint('Error adding comment: $e');
      return CommentResult.failure('Erreur lors de l\'ajout du commentaire');
    }
  }

  /// Delete a post
  Future<PostResult> deletePost(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return PostResult.failure('Utilisateur non connecté');
      }

      // Check if user owns the post
      final postDoc = await _firestore.collection(postsCollection).doc(postId).get();
      if (!postDoc.exists) {
        return PostResult.failure('Post non trouvé');
      }

      final postData = postDoc.data()!;
      if (postData['userId'] != currentUser.uid) {
        return PostResult.failure('Vous ne pouvez supprimer que vos propres posts');
      }

      // Delete associated data
      await _deletePostAssociatedData(postId);

      // Delete the post
      await _firestore.collection(postsCollection).doc(postId).delete();

      // Update user's post count
      await _firestore.collection('users').doc(currentUser.uid).update({
        'postCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete image from storage
      try {
        if (postData['imageUrl'] != null) {
          final ref = _storage.refFromURL(postData['imageUrl']);
          await ref.delete();
        }
      } catch (e) {
        debugPrint('Error deleting image from storage: $e');
      }

      return PostResult.success(postId);

    } catch (e) {
      debugPrint('Error deleting post: $e');
      return PostResult.failure('Erreur lors de la suppression du post');
    }
  }

  /// Get post likes
  Stream<List<LikeData>> getPostLikes(String postId) {
    return _firestore
        .collection(likesCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<LikeData> likes = [];

      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().isNotEmpty) {
          try {
            final userData = await _getUserData(doc.data()['userId']);
            if (userData != null) {
              likes.add(LikeData(
                userId: doc.data()['userId'],
                userName: userData.displayName,
                userProfileImageUrl: userData.profileImageUrl,
                createdAt: doc.data()['createdAt']?.toDate() ?? DateTime.now(),
              ));
            }
          } catch (e) {
            debugPrint('Error processing like: $e');
          }
        }
      }

      return likes;
    });
  }

  /// Get post comments
  Stream<List<CommentData>> getPostComments(String postId) {
    return _firestore
        .collection(commentsCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommentData.fromMap(doc.data());
      }).toList();
    });
  }

  // Private helper methods
  Future<PostData?> _enrichPostData(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final currentUser = _auth.currentUser;

      if (currentUser == null) return null;

      // Check if user liked this post
      final likeDoc = await _firestore
          .collection(likesCollection)
          .doc('${doc.id}_${currentUser.uid}')
          .get();

      // Check if user saved this post
      final saveDoc = await _firestore
          .collection(savedPostsCollection)
          .doc('${currentUser.uid}_${doc.id}')
          .get();

      data['isLiked'] = likeDoc.exists;
      data['isSaved'] = saveDoc.exists;

      return PostData.fromMap(data);
    } catch (e) {
      debugPrint('Error enriching post data: $e');
      return null;
    }
  }

  Future<UserData?> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<ImageUploadResult> _uploadImage(File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return ImageUploadResult.failure('Utilisateur non connecté');
      }

      final fileName = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('posts/$fileName');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return ImageUploadResult.success(downloadUrl);

    } catch (e) {
      debugPrint('Error uploading image: $e');
      return ImageUploadResult.failure('Erreur lors du téléchargement de l\'image');
    }
  }

  Future<void> _deletePostAssociatedData(String postId) async {
    try {
      // Delete all likes for this post
      final likesQuery = await _firestore
          .collection(likesCollection)
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in likesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete all comments for this post
      final commentsQuery = await _firestore
          .collection(commentsCollection)
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in commentsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete all saves for this post
      final savesQuery = await _firestore
          .collection(savedPostsCollection)
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in savesQuery.docs) {
        await doc.reference.delete();
      }

    } catch (e) {
      debugPrint('Error deleting post associated data: $e');
    }
  }
}

// Story Service
class StoryService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String storiesCollection = 'stories';

  /// Get stories stream
  Stream<List<StoryData>> getStoriesStream() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection(storiesCollection)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt', descending: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<StoryData> stories = [];

        for (var doc in snapshot.docs) {
          if (doc.exists && doc.data().isNotEmpty) {
            try {
              final userData = await _getUserData(doc.data()['userId']);
              if (userData != null) {
                final storyData = StoryData.fromMap({
                  ...doc.data(),
                  'userName': userData.displayName,
                  'userProfileImageUrl': userData.profileImageUrl,
                });
                stories.add(storyData);
              }
            } catch (e) {
              debugPrint('Error processing story: $e');
            }
          }
        }

        return stories;
      });
    } catch (e) {
      debugPrint('Error getting stories stream: $e');
      return Stream.value([]);
    }
  }

  /// Create a new story
  Future<StoryResult> createStory({
    required File mediaFile,
    String? text,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return StoryResult.failure('Utilisateur non connecté');
      }

      // Upload media to Firebase Storage
      final mediaUploadResult = await _uploadStoryMedia(mediaFile);
      if (!mediaUploadResult.success) {
        return StoryResult.failure(mediaUploadResult.errorMessage ?? 'Erreur lors du téléchargement');
      }

      // Create story document
      final storyRef = _firestore.collection(storiesCollection).doc();
      final expiresAt = DateTime.now().add(Duration(hours: 24));

      await storyRef.set({
        'id': storyRef.id,
        'userId': currentUser.uid,
        'mediaUrl': mediaUploadResult.mediaUrl,
        'text': text?.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      return StoryResult.success(storyRef.id);

    } catch (e) {
      debugPrint('Error creating story: $e');
      return StoryResult.failure('Erreur lors de la création de la story');
    }
  }

  Future<UserData?> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<MediaUploadResult> _uploadStoryMedia(File mediaFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return MediaUploadResult.failure('Utilisateur non connecté');
      }

      final fileName = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = _storage.ref().child('stories/$fileName');

      final uploadTask = ref.putFile(mediaFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return MediaUploadResult.success(downloadUrl);

    } catch (e) {
      debugPrint('Error uploading story media: $e');
      return MediaUploadResult.failure('Erreur lors du téléchargement');
    }
  }
}

// Result classes
class PostResult {
  final bool success;
  final String? postId;
  final String? errorMessage;

  PostResult({required this.success, this.postId, this.errorMessage});

  factory PostResult.success(String postId) => PostResult(success: true, postId: postId);
  factory PostResult.failure(String message) => PostResult(success: false, errorMessage: message);
}

class LikeResult {
  final bool success;
  final bool isLiked;
  final String? errorMessage;

  LikeResult({required this.success, required this.isLiked, this.errorMessage});

  factory LikeResult.success(bool isLiked) => LikeResult(success: true, isLiked: isLiked);
  factory LikeResult.failure(String message) => LikeResult(success: false, isLiked: false, errorMessage: message);
}

class SaveResult {
  final bool success;
  final bool isSaved;
  final String? errorMessage;

  SaveResult({required this.success, required this.isSaved, this.errorMessage});

  factory SaveResult.success(bool isSaved) => SaveResult(success: true, isSaved: isSaved);
  factory SaveResult.failure(String message) => SaveResult(success: false, isSaved: false, errorMessage: message);
}

class CommentResult {
  final bool success;
  final String? commentId;
  final String? errorMessage;

  CommentResult({required this.success, this.commentId, this.errorMessage});

  factory CommentResult.success(String commentId) => CommentResult(success: true, commentId: commentId);
  factory CommentResult.failure(String message) => CommentResult(success: false, errorMessage: message);
}

class StoryResult {
  final bool success;
  final String? storyId;
  final String? errorMessage;

  StoryResult({required this.success, this.storyId, this.errorMessage});

  factory StoryResult.success(String storyId) => StoryResult(success: true, storyId: storyId);
  factory StoryResult.failure(String message) => StoryResult(success: false, errorMessage: message);
}

class ImageUploadResult {
  final bool success;
  final String? imageUrl;
  final String? errorMessage;

  ImageUploadResult({required this.success, this.imageUrl, this.errorMessage});

  factory ImageUploadResult.success(String imageUrl) => ImageUploadResult(success: true, imageUrl: imageUrl);
  factory ImageUploadResult.failure(String message) => ImageUploadResult(success: false, errorMessage: message);
}

class MediaUploadResult {
  final bool success;
  final String? mediaUrl;
  final String? errorMessage;

  MediaUploadResult({required this.success, this.mediaUrl, this.errorMessage});

  factory MediaUploadResult.success(String mediaUrl) => MediaUploadResult(success: true, mediaUrl: mediaUrl);
  factory MediaUploadResult.failure(String message) => MediaUploadResult(success: false, errorMessage: message);
}

// Data models
class LikeData {
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final DateTime createdAt;

  LikeData({
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.createdAt,
  });
}

class CommentData {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final String comment;
  final DateTime createdAt;

  CommentData({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.comment,
    required this.createdAt,
  });

  factory CommentData.fromMap(Map<String, dynamic> map) {
    return CommentData(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImageUrl: map['userProfileImageUrl'],
      comment: map['comment'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}

// Data models for the home screen
class PostData {
  final String id;
  final String userId;
  final String userName;
  final String userAcademicYear;
  final String userSpecialty;
  final String? userProfileImageUrl;
  final bool userIsVerified;
  final String imageUrl;
  final String caption;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  PostData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAcademicYear,
    required this.userSpecialty,
    this.userProfileImageUrl,
    required this.userIsVerified,
    required this.imageUrl,
    required this.caption,
    this.location,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  factory PostData.fromMap(Map<String, dynamic> map) {
    return PostData(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAcademicYear: map['userAcademicYear'] ?? '',
      userSpecialty: map['userSpecialty'] ?? '',
      userProfileImageUrl: map['userProfileImageUrl'],
      userIsVerified: map['userIsVerified'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      location: map['location'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      isSaved: map['isSaved'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAcademicYear': userAcademicYear,
      'userSpecialty': userSpecialty,
      'userProfileImageUrl': userProfileImageUrl,
      'userIsVerified': userIsVerified,
      'imageUrl': imageUrl,
      'caption': caption,
      'location': location,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class StoryData {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final String mediaUrl;
  final String? text;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryData({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.mediaUrl,
    this.text,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryData.fromMap(Map<String, dynamic> map) {
    return StoryData(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImageUrl: map['userProfileImageUrl'],
      mediaUrl: map['mediaUrl'] ?? '',
      text: map['text'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      expiresAt: map['expiresAt']?.toDate() ?? DateTime.now().add(Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}

// RefreshController for pull-to-refresh functionality
class RefreshController {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  void startRefresh() {
    _isRefreshing = true;
  }

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void refreshFailed() {
    _isRefreshing = false;
  }
}