import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentController = TextEditingController();
  final _bedroomsController = TextEditingController(text: '1');
  final _bathroomsController = TextEditingController(text: '1');
  final _amenitiesController = TextEditingController();
  final _tagsController = TextEditingController();

  final RoomService _roomService = RoomService();
  bool _loading = false;
  String _selectedStatus = 'available';

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) return 'Title is required';
    if (value.length < 5) return 'Title must be at least 5 characters';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Description is required';
    if (value.length < 20) return 'Description must be at least 20 characters';
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) return 'Location is required';
    return null;
  }

  String? _validateRent(String? value) {
    if (value == null || value.isEmpty) return 'Rent is required';
    if (double.tryParse(value) == null || double.parse(value) < 0) {
      return 'Enter a valid rent amount';
    }
    return null;
  }

  String? _validateBedrooms(String? value) {
    if (value == null || value.isEmpty) return 'Bedrooms required';
    if (int.tryParse(value) == null || int.parse(value) < 1) {
      return 'Must be at least 1 bedroom';
    }
    return null;
  }

  String? _validateBathrooms(String? value) {
    if (value == null || value.isEmpty) return 'Bathrooms required';
    if (int.tryParse(value) == null || int.parse(value) < 1) {
      return 'Must be at least 1 bathroom';
    }
    return null;
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Get owner name from user's displayName or email
      final ownerName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Anonymous';

      final amenities = _amenitiesController.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final now = DateTime.now();
      final room = Room(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        rent: double.parse(_rentController.text),
        bedrooms: int.parse(_bedroomsController.text),
        bathrooms: int.parse(_bathroomsController.text),
        amenities: amenities,
        ownerId: uid,
        ownerName: ownerName,
        status: _selectedStatus,
        tags: tags,
        createdAt: now,
        updatedAt: now,
      );

      await _roomService.createRoom(room);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
      }
    } catch (e) {
      _showError('Error: ${e.toString().split('\n').first}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Semantics(
                label: 'Title input field',
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Cozy 2BR Downtown Apartment',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: _validateTitle,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Description input field',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the room/apartment, features, etc. (minimum 20 characters)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateDescription,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Location input field',
                child: TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., 123 Main St, Downtown',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: _validateLocation,
              ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Rent per month input field',
                      child: TextFormField(
                        controller: _rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Rent (\$/mo)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: _validateRent,
                    ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Number of bedrooms input field',
                      child: TextFormField(
                        controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bedrooms',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bed),
                      ),
                      validator: _validateBedrooms,
                    ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Number of bathrooms input field',
                      child: TextFormField(
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Bathrooms',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bathtub),
                        ),
                        validator: _validateBathrooms,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amenitiesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Amenities (comma-separated)',
                  hintText: 'e.g., WiFi, Parking, Laundry, AC',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  hintText: 'e.g., pet-friendly, furnished, near-transit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['available', 'pending', 'rented']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createRoom,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
