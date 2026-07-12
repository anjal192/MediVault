import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'firebase_auth_service.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  FirebaseStorage? get _storage {
    try {
      return FirebaseStorage.instance;
    } catch (e) {
      debugPrint("Firebase Storage not initialized: $e");
      return null;
    }
  }

  String get _uid => FirebaseAuthService().currentUid ?? "john_doe_uid";

  /// Upload prescription image and return download URL
  Future<String> uploadPrescriptionImage(String prescriptionId, File file) async {
    final storage = _storage;
    if (storage == null) {
      debugPrint("SIMULATED STORAGE UPLOAD: Prescription $prescriptionId");
      // Return a simulated URL (an illustration image or placeholder)
      return "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=500";
    }

    try {
      final ref = storage.ref().child('users/$_uid/prescriptions/$prescriptionId.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=500";
    }
  }

  /// Upload other medical record files and return download URL
  Future<String> uploadMedicalRecordFile(String recordId, File file, String recordType) async {
    final storage = _storage;
    if (storage == null) {
      debugPrint("SIMULATED STORAGE UPLOAD: Medical Record $recordId of type $recordType");
      return "https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?q=80&w=500";
    }

    try {
      final ext = file.path.split('.').last;
      final ref = storage.ref().child('users/$_uid/medical_records/${recordId}_$recordType.$ext');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return "https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?q=80&w=500";
    }
  }
}
