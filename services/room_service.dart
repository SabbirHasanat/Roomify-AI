import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';

class RoomService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth? _auth;

  RoomService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth;

  // Create a new room
  Future<String> createRoom(Room room) async {
    try {
      final docRef = await _firestore.collection('rooms').add(room.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  // Get a single room by ID
  Future<Room?> getRoom(String roomId) async {
    try {
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return Room.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
  }

  // Get all rooms (public listing)
  Stream<List<Room>> getAllRooms() {
    return _firestore
        .collection('rooms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Get rooms by current user (my listings)
  Stream<List<Room>> getUserRooms() {
    final uid = _auth?.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('rooms')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // Update a room (owner only)
  Future<void> updateRoom(String roomId, Room room) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update(room.toJson());
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

  // Delete a room (owner only)
  Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).delete();
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }

  // Toggle favorite for a room by the current user
  Future<List<String>> toggleFavorite(String roomId, String userId) async {
    final docRef = _firestore.collection('rooms').doc(roomId);
    try {
      final result = await _firestore.runTransaction<List<String>>((tx) async {
        final snapshot = await tx.get(docRef);
        if (!snapshot.exists) throw Exception('Room not found');

        final data = snapshot.data()!;
        final List<dynamic> current = data['favoritedBy'] ?? [];
        final favs = current.map((e) => e.toString()).toList();

        if (favs.contains(userId)) {
          tx.update(docRef, {
            'favoritedBy': FieldValue.arrayRemove([userId])
          });
          favs.remove(userId);
        } else {
          tx.update(docRef, {
            'favoritedBy': FieldValue.arrayUnion([userId])
          });
          favs.add(userId);
        }

        return favs;
      });

      return result;
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Submit a rating for a room and update average + count atomically
  Future<void> submitRating(String roomId, String userId, double rating,
      {String? review}) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final ratingsRef = roomRef.collection('ratings');
    try {
      await _firestore.runTransaction<void>((tx) async {
        final roomSnap = await tx.get(roomRef);
        if (!roomSnap.exists) throw Exception('Room not found');

        final roomData = roomSnap.data()!;
        final ratingVal = roomData['rating'];
        final countVal = roomData['reviewCount'];
        final double oldAvg = ratingVal is num ? ratingVal.toDouble() : 0.0;
        final int oldCount = countVal is int
          ? countVal
          : (countVal is num ? countVal.toInt() : 0);

        final int newCount = oldCount + 1;
        final double newAvg = ((oldAvg * oldCount) + rating) / newCount;

        // Add rating document (auto id)
        final newRating = {
          'userId': userId,
          'rating': rating,
          'review': review ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        tx.set(ratingsRef.doc(), newRating);

        // Update room aggregate
        tx.update(roomRef, {
          'rating': newAvg,
          'reviewCount': newCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }
}
