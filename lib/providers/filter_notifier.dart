import 'package:flutter/material.dart';

class FilterNotifier extends ChangeNotifier {
  double _minRent = 0;
  double _maxRent = 5000;
  int? _minBedrooms;
  int? _maxBedrooms;
  final List<String> _selectedAmenities = [];
  bool _showFavoritesOnly = false;
  String _searchQuery = '';

  double get minRent => _minRent;
  double get maxRent => _maxRent;
  int? get minBedrooms => _minBedrooms;
  int? get maxBedrooms => _maxBedrooms;
  List<String> get selectedAmenities => _selectedAmenities;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _minRent > 0 ||
      _maxRent < 5000 ||
      _minBedrooms != null ||
      _maxBedrooms != null ||
      _selectedAmenities.isNotEmpty ||
      _showFavoritesOnly ||
      _searchQuery.isNotEmpty;

  void setRentRange(double min, double max) {
    _minRent = min;
    _maxRent = max;
    notifyListeners();
  }

  void setBedroomRange(int? min, int? max) {
    _minBedrooms = min;
    _maxBedrooms = max;
    notifyListeners();
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  void clearAmenities() {
    _selectedAmenities.clear();
    notifyListeners();
  }

  void toggleFavorites() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _minRent = 0;
    _maxRent = 5000;
    _minBedrooms = null;
    _maxBedrooms = null;
    _selectedAmenities.clear();
    _showFavoritesOnly = false;
    _searchQuery = '';
    notifyListeners();
  }
}
