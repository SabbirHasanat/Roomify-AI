import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;

  const RoomDetailPage({required this.room, super.key});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final RoomService _roomService = RoomService();
  late Room _room;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = uid == _room.ownerId;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: isMobile
            ? _buildMobileLayout(isOwner)
            : _buildDesktopLayout(isOwner),
      ),
    );
  }

  Widget _buildMobileLayout(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(),
        const SizedBox(height: 20),
        _buildTitleSection(),
        const SizedBox(height: 16),
        _buildRatingSection(),
        const SizedBox(height: 16),
        _buildDetailsGrid(),
        const SizedBox(height: 20),
        _buildLocationSection(),
        const SizedBox(height: 16),
        _buildDescriptionSection(),
        const SizedBox(height: 16),
        _buildAmenitiesSection(),
        const SizedBox(height: 16),
        _buildTagsSection(),
        const SizedBox(height: 24),
        _buildActionButtons(isOwner),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isOwner) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: image
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: 20),
              _buildAmenitiesSection(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right column: details
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(),
              const SizedBox(height: 16),
              _buildRatingSection(),
              const SizedBox(height: 16),
              _buildDetailsGrid(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildDescriptionSection(),
              const SizedBox(height: 16),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildActionButtons(isOwner),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Semantics(
      image: true,
      label: 'Room image for ${_room.title}',
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          image: _room.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_room.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _room.imageUrl == null
            ? Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey[500],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _room.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _room.location,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Chip(
          label: Text(_room.status),
          backgroundColor: _room.status == 'available'
              ? Colors.green[100]
              : _room.status == 'pending'
                  ? Colors.yellow[100]
                  : Colors.grey[300],
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        i < _room.rating.toInt() ? Icons.star : Icons.star_border,
                        size: 18,
                        color: Colors.amber[600],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_room.rating.toStringAsFixed(1)} (${_room.reviewCount} reviews)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'By ${_room.ownerName}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 20,
                  child: Text(_room.ownerName.substring(0, 1).toUpperCase()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        _buildDetailCard('Bedrooms', '${_room.bedrooms}', Icons.bed),
        _buildDetailCard('Bathrooms', '${_room.bathrooms}', Icons.bathtub),
        _buildDetailCard('Rent', '\$${_room.rent.toStringAsFixed(0)}/mo',
            Icons.attach_money),
        _buildDetailCard('Status', _room.status, Icons.info),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_room.location),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(_room.description),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_room.amenities.isNotEmpty)
          Text('Amenities',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_room.amenities.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _room.amenities
                .map((amenity) => Chip(
                      label: Text(amenity),
                      backgroundColor: Colors.deepPurple[50],
                    ))
                .toList(),
          )
        else
          Text('No amenities listed',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_room.tags.isNotEmpty)
          Text('Tags',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_room.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _room.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.amber[100],
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildActionButtons(bool isOwner) {
    return Column(
      children: [
        if (isOwner)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: 'Edit this room listing',
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Edit feature coming soon')),
                      );
                    },
                    child: const Text('Edit Listing'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: 'Permanently delete this room listing',
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () => _deleteRoom(),
                    child: const Text('Delete Listing',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Tooltip(
                  message: 'Express interest in this room',
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Contact feature coming soon')),
                      );
                    },
                    child: const Text('Interest in This Room?'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Show rating dialog
                    _showRatingDialog();
                  },
                  child: const Text('Leave a Review'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate This Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => setState(() => _userRating = i.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        i <= _userRating ? Icons.star : Icons.star_border,
                        size: 32,
                        color: Colors.amber[600],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in to submit a review')),
                );
                return;
              }

              final chosen = _userRating;
              if (chosen <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a star rating first')),
                );
                return;
              }

              Navigator.pop(context);

              // Optimistic update: compute and show updated average immediately
              final prevAvg = _room.rating;
              final prevCount = _room.reviewCount;
              final newCount = prevCount + 1;
              final newAvg = ((prevAvg * prevCount) + chosen) / newCount;

              setState(() {
                _room = _room.copyWith(rating: newAvg, reviewCount: newCount);
              });

              try {
                await _roomService.submitRating(_room.id!, uid, chosen);
                // Refresh room data from server to ensure correctness
                final updated = await _roomService.getRoom(_room.id!);
                if (updated != null && mounted) setState(() => _room = updated);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rating submitted!')),
                  );
                }
              } catch (e) {
                // revert optimistic update on error
                if (mounted) {
                  setState(() => _room = _room.copyWith(rating: prevAvg, reviewCount: prevCount));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting rating: $e')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _deleteRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _roomService.deleteRoom(_room.id!);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
