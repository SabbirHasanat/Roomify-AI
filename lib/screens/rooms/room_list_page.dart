import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../providers/room_notifier.dart';
import '../../providers/filter_notifier.dart';
import 'room_detail_page.dart';
import 'create_room_page.dart';
import '../../widgets/advanced_filter_sheet.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final RoomService _roomService = RoomService();
  final TextEditingController _searchController = TextEditingController();
  // track optimistic favorite toggles per room id
  final Map<String, bool> _optimisticFav = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomListNotifier>().resetView();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Room> _applyFilters(List<Room> rooms) {
    final filter = context.read<FilterNotifier>();
    
    return rooms.where((room) {
      // Rent filter
      if (room.rent < filter.minRent || room.rent > filter.maxRent) return false;

      // Bedrooms filter
      if (filter.minBedrooms != null && room.bedrooms < filter.minBedrooms!) {
        return false;
      }

      // Amenities filter
      if (filter.selectedAmenities.isNotEmpty) {
        for (String amenity in filter.selectedAmenities) {
          if (!room.amenities.contains(amenity)) return false;
        }
      }

      // Search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        if (!room.title.toLowerCase().contains(query) &&
            !room.location.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final showMyListings = context.watch<RoomListNotifier>().showMyListings;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Roomify'),
        centerTitle: !isMobile,
        actions: [
          TextButton.icon(
            onPressed: () =>
                context.read<RoomListNotifier>().toggleListingView(),
            icon: Icon(showMyListings ? Icons.list : Icons.home),
            label: Text(showMyListings ? 'All Rooms' : 'My Listings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      context.read<FilterNotifier>().setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => const AdvancedFilterSheet(),
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                    );
                  },
                  child: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          // Room List
          Expanded(
            child: StreamBuilder<List<Room>>(
              stream: showMyListings
                  ? _roomService.getUserRooms()
                  : _roomService.getAllRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allRooms = snapshot.data ?? [];
                final filteredRooms = _applyFilters(allRooms);

                if (filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          showMyListings
                              ? 'No listings yet'
                              : 'No rooms available',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                return isMobile
                    ? _buildMobileList(filteredRooms, uid)
                    : _buildResponsiveGrid(filteredRooms, uid);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateRoomPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
    );
  }

  Widget _buildMobileList(List<Room> rooms, String? uid) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _buildRoomCard(room, uid, context);
      },
    );
  }

  Widget _buildResponsiveGrid(List<Room> rooms, String? uid) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _buildRoomCard(room, uid, context);
      },
    );
  }

  Widget _buildRoomCard(Room room, String? uid, BuildContext context) {
    final isFavorited = (room.id != null && _optimisticFav.containsKey(room.id))
      ? (_optimisticFav[room.id] ?? false)
      : (uid != null && room.favoritedBy.contains(uid));
    final semanticLabel =
        '${room.title}, ${room.location}, \$${room.rent}/mo, ${room.bedrooms}BR, ${room.bathrooms}BA, ${room.rating.toStringAsFixed(1)} stars';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        image: room.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(room.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: room.imageUrl == null
                          ? Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey[500],
                              ),
                            )
                          : null,
                    ),
                    // Status badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text(room.status),
                        backgroundColor: room.status == 'available'
                            ? Colors.green[100]
                            : room.status == 'pending'
                                ? Colors.yellow[100]
                                : Colors.grey[300],
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.title,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  room.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${room.rent.toStringAsFixed(0)}/mo',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                '${room.bedrooms}BR • ${room.bathrooms}BA',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 14, color: Colors.amber[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    room.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              if (room.reviewCount > 0)
                                Text(
                                  '(${room.reviewCount})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (room.ownerId == uid)
                                Tooltip(
                                  message: 'Delete this listing',
                                  child: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Text('Delete'),
                                        onTap: () => _deleteRoom(room.id!),
                                      ),
                                    ],
                                  ),
                                )
                                else
                                Tooltip(
                                  message: isFavorited ? 'Remove from favorites' : 'Add to favorites',
                                  child: GestureDetector(
                                    onTap: () async {
                                      final uid = FirebaseAuth.instance.currentUser?.uid;
                                      if (uid == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please sign in to save favorites')),
                                        );
                                        return;
                                      }

                                      // Optimistic update: flip local state immediately
                                      final rid = room.id;
                                      if (rid == null) return;
                                      final previous = _optimisticFav[rid] ?? room.favoritedBy.contains(uid);
                                      setState(() => _optimisticFav[rid] = !previous);

                                      try {
                                        await _roomService.toggleFavorite(rid, uid);
                                        // success - stream will reflect server state
                                        // clear optimistic entry
                                        setState(() => _optimisticFav.remove(rid));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(!previous ? 'Added to favorites' : 'Removed from favorites')),
                                        );
                                      } catch (e) {
                                        // revert optimistic change
                                        setState(() => _optimisticFav[rid] = previous);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error toggling favorite: $e')),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      isFavorited ? Icons.favorite : Icons.favorite_border,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteRoom(String roomId) {
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
                await _roomService.deleteRoom(roomId);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
