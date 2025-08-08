import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/uniform_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new uniform record
  Future<void> addRecord(UniformModel uniform) async {
    await _db.collection('uniforms').add(uniform.toMap());
  }

  // Update an existing uniform record
  Future<void> updateRecord(String docId, UniformModel uniform) async {
    await _db.collection('uniforms').doc(docId).update(uniform.toMap());
  }

  // Delete a uniform record
  Future<void> deleteRecord(String docId) async {
    await _db.collection('uniforms').doc(docId).delete();
  }

  // Get a stream of uniform records
  Stream<List<UniformModel>> getUniformsStream() {
    return _db
        .collection('uniforms')
        .orderBy('timestamp', descending: true) // Order by timestamp
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UniformModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}
