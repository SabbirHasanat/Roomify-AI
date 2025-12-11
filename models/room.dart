import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String? id; // Firestore doc ID
  final String title;
  final String description;
  final String location;
  final double rent;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final String? imageUrl;
  final String ownerId;
  final String ownerName; // Owner's display name
  final String status; // 'available', 'pending', 'rented'
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating; // Average rating (0-5)
  final int reviewCount; // Number of reviews
  final List<String> favoritedBy; // UIDs of users who favorited

  Room({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.rent,
    required this.bedrooms,
    required this.bathrooms,
    this.amenities = const [],
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.favoritedBy = const [],
  });

  // Convert Room to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'rent': rent,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'reviewCount': reviewCount,
      'favoritedBy': favoritedBy,
    };
  }

  // Create Room from Firestore JSON
  factory Room.fromJson(Map<String, dynamic> json, String docId) {
    return Room(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      amenities: List<String>.from(json['amenities'] ?? []),
      imageUrl: json['imageUrl'],
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? 'Owner',
      status: json['status'] ?? 'available',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      favoritedBy: List<String>.from(json['favoritedBy'] ?? []),
    );
  }

  // Copy with method for updates
  Room copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    double? rent,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    String? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    List<String>? favoritedBy,
  }) {
    return Room(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      rent: rent ?? this.rent,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      favoritedBy: favoritedBy ?? this.favoritedBy,
    );
  }
}
