import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return getUser(uid);
  }

  /// Create new user in Firestore
  Future<UserModel> createUser({
    required String username,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    String? photoUrl;

    // Upload profile image if provided
    if (profileImage != null) {
      photoUrl = await _uploadProfileImage(user.uid, profileImage);
    }

    // Create user model
    final userModel = UserModel.create(
      uid: user.uid,
      phone: user.phoneNumber ?? '',
      username: username,
      photoUrl: photoUrl,
    );

    // Save to Firestore
    await _usersCollection.doc(user.uid).set(userModel.toFirestore());

    return userModel;
  }

  /// Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(String uid, File image) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    
    // Upload file
    await ref.putFile(
      image,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // Get download URL
    return await ref.getDownloadURL();
  }

  /// Update user profile
  Future<void> updateUser({
    String? username,
    File? profileImage,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('No authenticated user');

    final updates = <String, dynamic>{};

    if (username != null) {
      updates['username'] = username;
    }

    if (profileImage != null) {
      final photoUrl = await _uploadProfileImage(uid, profileImage);
      updates['photoUrl'] = photoUrl;
    }

    if (updates.isNotEmpty) {
      await _usersCollection.doc(uid).update(updates);
    }
  }

  /// Update user stats after match completion for a specific category
  Future<void> updateUserStats({
    required String category,
    required int newMatchScore,
    required double newMatchAccuracy,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    final user = await getUser(uid);
    if (user == null) return;

    // Get current stats for this category
    final currentStats = user.getStats(category);

    // Calculate new averages for this category
    final newTotalMatches = currentStats.totalMatches + 1;
    final newAvgAccuracy = ((currentStats.avgAccuracy * currentStats.totalMatches) + newMatchAccuracy) / newTotalMatches;
    final newBestScore = newMatchScore > currentStats.bestScore ? newMatchScore : currentStats.bestScore;

    // Update only this category's stats
    await _usersCollection.doc(uid).update({
      'categoryStats.$category.totalMatches': newTotalMatches,
      'categoryStats.$category.avgAccuracy': newAvgAccuracy,
      'categoryStats.$category.bestScore': newBestScore,
    });
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
