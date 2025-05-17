import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file
  Future<String> uploadFile(File file, String path) async {
    TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();
  }
}