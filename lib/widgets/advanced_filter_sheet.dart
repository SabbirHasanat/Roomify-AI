import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/filter_notifier.dart';

class AdvancedFilterSheet extends StatefulWidget {
  const AdvancedFilterSheet({super.key});

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  final List<String> commonAmenities = [
    'WiFi',
    'Parking',
    'AC',
    'Heating',
    'Furnished',
    'Balcony',
    'Kitchen',
    'Laundry',
    'Gym',
    'Pool',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterNotifier>(
      builder: (context, filter, _) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (filter.hasActiveFilters)
                        TextButton.icon(
                          onPressed: () => filter.resetFilters(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Rent Range Slider
                  Text(
                    'Rent Range: \$${filter.minRent.toStringAsFixed(0)} - \$${filter.maxRent.toStringAsFixed(0)}/mo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RangeSlider(
                    values: RangeValues(filter.minRent, filter.maxRent),
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    labels: RangeLabels(
                      '\$${filter.minRent.toStringAsFixed(0)}',
                      '\$${filter.maxRent.toStringAsFixed(0)}',
                    ),
                    onChanged: (RangeValues values) {
                      filter.setRentRange(values.start, values.end);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bedrooms
                  Text(
                    'Bedrooms',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('$i+'),
                              selected: filter.minBedrooms == i,
                              onSelected: (selected) {
                                filter.setBedroomRange(
                                  selected ? i : null,
                                  filter.maxBedrooms,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (String amenity in commonAmenities)
                        FilterChip(
                          label: Text(amenity),
                          selected: filter.selectedAmenities.contains(amenity),
                          onSelected: (_) => filter.toggleAmenity(amenity),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
