// Search Delegate for Trip Search
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/travel_model.dart';
import '../../domain/entities/travel_entity.dart';
import '../../routes.dart';

class TripSearchDelegate extends SearchDelegate {
  // Text Color Constants
  static const Color primeryColor = AppTheme.primaryColor;
  static const Color blackTextColor = Colors.black;
  static const Color greyTextColor = Colors.grey;
  static const Color whiteColor = AppTheme.whiteColor;
  static const Color greyIconColor = Colors.grey;

  final List<TravelEntity> travels;

  TripSearchDelegate(this.travels);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.primaryColor, // AppBar background color
        foregroundColor: whiteColor, // Icons color
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: whiteColor, // Cursor color
        selectionColor: whiteColor.withOpacity(0.3), // Text selection color
        selectionHandleColor: whiteColor, // Selection handle color
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: whiteColor.withOpacity(0.7), // Hint text color
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: whiteColor, // This is the typing text color
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Please enter a search term'));
    }

    final results =
        travels.where((travel) {
          return travel.destination.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              travel.startingLocation.toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: greyIconColor),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: TextStyle(color: whiteColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final travel = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text('${travel.startingLocation} → ${travel.destination}'),
            subtitle: Text(
              '${travel.createdAt.day}/${travel.createdAt.month}/${travel.createdAt.year} • ${_getTravelStatusString(travel.travelStatus)}',
            ),
            leading: const Icon(Icons.flight),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              close(context, null);
              Navigator.pushNamed(
                context,
                AppRoutes.historyDetail,
                arguments: {'historyId': travel.id},
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Searches',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Paris'),
            onTap: () {
              query = 'Paris';
              showResults(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Tokyo'),
            onTap: () {
              query = 'Tokyo';
              showResults(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Popular Destinations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('New York'),
            onTap: () {
              query = 'New York';
              showResults(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flight),
            title: const Text('London'),
            onTap: () {
              query = 'London';
              showResults(context);
            },
          ),
        ],
      );
    }

    final suggestions =
        travels
            .where((travel) {
              return travel.destination.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  travel.startingLocation.toLowerCase().contains(
                    query.toLowerCase(),
                  );
            })
            .take(5)
            .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final travel = suggestions[index];
        final destinationMatch = travel.destination.toLowerCase().contains(
          query.toLowerCase(),
        );
        final originMatch = travel.startingLocation.toLowerCase().contains(
          query.toLowerCase(),
        );

        return ListTile(
          leading: const Icon(Icons.flight),
          title:
              destinationMatch
                  ? RichText(
                    text: TextSpan(
                      children: _highlightMatch(travel.destination, query),
                      style: TextStyle(color: blackTextColor),
                    ),
                  )
                  : Text(travel.destination),
          subtitle:
              originMatch
                  ? RichText(
                    text: TextSpan(
                      children: _highlightMatch(
                        'From: ${travel.startingLocation}',
                        query,
                      ),
                      style: TextStyle(color: greyTextColor),
                    ),
                  )
                  : Text('From: ${travel.startingLocation}'),
          onTap: () {
            query =
                destinationMatch ? travel.destination : travel.startingLocation;
            showResults(context);
          },
        );
      },
    );
  }

  List<TextSpan> _highlightMatch(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while (true) {
      indexOfMatch = lowerText.indexOf(lowerQuery, start);
      if (indexOfMatch == -1) {
        // Add the rest of the string
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      // Add the text before the match
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }

      // Add the match with highlight
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: TextStyle(fontWeight: FontWeight.bold, color: whiteColor),
        ),
      );

      start = indexOfMatch + query.length;
    }

    return spans;
  }

  String _getTravelStatusString(TravelStatus status) {
    switch (status) {
      case TravelStatus.ON_GOING:
        return 'Ongoing';
      case TravelStatus.COMPLETED:
        return 'Completed';
      case TravelStatus.CANCELLED:
        return 'Cancelled';
    }
  }
}
