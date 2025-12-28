import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static Future<String?> uploadJournalImage(File imageFile) async {
    try {
      // Create a unique filename using timestamp
      String fileName = path.basename(imageFile.path);
      Reference ref = _storage.ref().child('journal_images/$fileName');

      // Upload the file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Return the permanent web URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }
}
