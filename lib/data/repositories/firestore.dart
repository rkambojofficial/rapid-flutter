import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirestoreRepository {
  static final firestore = FirebaseFirestore.instance;
  static final database = FirebaseDatabase.instance;

  static Future<void> setUserData(String id, Map<String, dynamic> data) {
    return firestore.collection('users').doc(id).set(data);
  }

  static Future<DocumentSnapshot> getUserData(String id) {
    return firestore.collection('users').doc(id).get();
  }

  static Future<QuerySnapshot> findUser(String email) {
    return firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
  }

  static CollectionReference updatesRef(String userId) {
    return firestore.collection('users').doc(userId).collection('updates');
  }

  static Stream<QuerySnapshot> updates(String userId, int startAfter) {
    return updatesRef(userId).orderBy('createdAt').startAfter([startAfter]).snapshots();
  }

  static DocumentReference update(String userId, {String id}) {
    return updatesRef(userId).doc(id);
  }

  static Future<QuerySnapshot> findChat(String chatUserId, String userId) {
    return updatesRef(chatUserId).where('type', isEqualTo: 'Chat').where('userId', isEqualTo: userId).limit(1).get();
  }

  static Stream<Event> userStatus(String id) {
    return database.reference().child('status').child(id).onValue;
  }

  static Future<void> setUserStatus(String id, Map<String, dynamic> data) {
    return database.reference().child('status').child(id).update(data);
  }
}
