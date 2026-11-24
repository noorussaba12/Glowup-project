import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/scan_model.dart';
import 'storage_service.dart';

class FirebaseService {
  static bool isFirebaseInitialized = false;

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      isFirebaseInitialized = true;
    } catch (e) {
      debugPrint('Firebase initialization notice: $e (Falling back to local simulation mode)');
      isFirebaseInitialized = false;
    }
  }

  // Auth Getters
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  static User? get currentFirebaseUser => isFirebaseInitialized ? _auth.currentUser : null;
  static String get currentUserId => currentFirebaseUser?.uid ?? 'guest_user_123';

  // 1. Sign Up
  static Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    required int age,
  }) async {
    if (isFirebaseInitialized) {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        age: age,
        gender: LocalStorageService.userGender,
        theme: LocalStorageService.userGender == 'male' ? 'blue' : 'pink',
        consentAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } else {
      // Local simulated user
      final userModel = UserModel(
        uid: 'simulated_user_01',
        email: email,
        displayName: displayName,
        age: age,
        gender: LocalStorageService.userGender,
        theme: LocalStorageService.userGender == 'male' ? 'blue' : 'pink',
        consentAt: DateTime.now(),
      );
      return userModel;
    }
  }

  // 2. Sign In
  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (isFirebaseInitialized) {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return UserModel(
        uid: uid,
        email: email,
        displayName: credential.user!.displayName ?? 'Glow User',
      );
    } else {
      return UserModel(
        uid: 'simulated_user_01',
        email: email,
        displayName: 'Demo User',
      );
    }
  }

  // 3. Update User Gender / Theme
  static Future<void> updateUserGender(String gender) async {
    await LocalStorageService.setUserGender(gender);
    if (isFirebaseInitialized && currentFirebaseUser != null) {
      await _firestore.collection('users').doc(currentUserId).update({
        'gender': gender,
        'theme': gender == 'male' ? 'blue' : 'pink',
      });
    }
  }

  // 4. Save Scan Record
  static Future<void> saveScanRecord(ScanRecord record, {File? imageFile}) async {
    String? storageUrl;

    if (isFirebaseInitialized && imageFile != null && currentFirebaseUser != null) {
      try {
        final ref = _storage.ref().child('users/$currentUserId/scans/${record.id}.jpg');
        final uploadTask = await ref.putFile(imageFile);
        storageUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image to Firebase Storage: $e');
      }
    }

    final dataToSave = record.toMap();
    if (storageUrl != null) {
      dataToSave['storageImageUrl'] = storageUrl;
    }

    if (isFirebaseInitialized && currentFirebaseUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .doc(record.id)
          .set(dataToSave);
    }

    // Always mirror to local offline cache
    await LocalStorageService.saveOfflineScan(dataToSave);
  }

  // 5. Fetch Scan History
  static Future<List<ScanRecord>> fetchScans() async {
    if (isFirebaseInitialized && currentFirebaseUser != null) {
      try {
        final snap = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('scans')
            .orderBy('createdAt', descending: true)
            .get();

        return snap.docs.map((doc) => ScanRecord.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        debugPrint('Error fetching scans from Firestore: $e');
      }
    }

    // Fallback to offline scans
    final offlineList = LocalStorageService.getOfflineScans();
    return offlineList.map((m) => ScanRecord.fromMap(m, m['id'] ?? 'scan_0')).toList();
  }

  // 6. Delete History
  static Future<void> deleteScanHistory() async {
    if (isFirebaseInitialized && currentFirebaseUser != null) {
      final snap = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
    await LocalStorageService.prefs.remove('glow_offline_scans');
  }

  // 7. Delete Account and All Data
  static Future<void> deleteAccountAndAllData() async {
    await deleteScanHistory();
    if (isFirebaseInitialized && currentFirebaseUser != null) {
      await _firestore.collection('users').doc(currentUserId).delete();
      await currentFirebaseUser?.delete();
    }
    await LocalStorageService.clearAllData();
  }

  // 8. Sign Out
  static Future<void> signOut() async {
    if (isFirebaseInitialized) {
      await _auth.signOut();
    }
  }
}
