import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final StorageReference storageRef = FirebaseStorage.instance.ref();

  Future<FirebaseStorageResult> uploadFile(FirebaseUser user, File file, String filename) async {
    StorageReference storageReference;
    
    storageReference = FirebaseStorage.instance.ref().child('stock_management').child(user.uid).child("images/$filename");

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot storageSnapshot = (await uploadTask.onComplete);
    var downloadUrl = await storageSnapshot.ref.getDownloadURL();

    if (uploadTask.isComplete) {
      var url = downloadUrl.toString();
      return FirebaseStorageResult(
        imageUrl: url,
        imageFileName: filename,
      );
    }

    return null;
  }
}

class FirebaseStorageResult {
  final String imageUrl;
  final String imageFileName;
  FirebaseStorageResult({this.imageUrl, this.imageFileName});
}