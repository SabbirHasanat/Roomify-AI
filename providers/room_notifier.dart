import 'package:flutter/material.dart';

class RoomListNotifier extends ChangeNotifier {
  bool _showMyListings = false;

  bool get showMyListings => _showMyListings;

  void toggleListingView() {
    _showMyListings = !_showMyListings;
    notifyListeners();
  }

  void resetView() {
    _showMyListings = false;
  }
}

class RoomCreateNotifier extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createRoom(String title, String description, String location,
      double rent, int bedrooms, int bathrooms, List<String> amenities,
      List<String> tags, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implementation handled in UI for now
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
