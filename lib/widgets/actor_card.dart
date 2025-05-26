import 'package:flutter/material.dart';
import '../core/app_assets.dart';

class Actor {
  final String name;
  final String? characterName;
  final String urlSmallImage;

  Actor({
    required this.name,
    this.characterName,
    required this.urlSmallImage,
  });
}

class ActorCard extends StatelessWidget {
  final  actor;

  const ActorCard({
    Key? key,
    required this.actor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppAssets.gray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Actor Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              actor.urlSmallImage,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 70,
                  width: 70,
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Actor Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${actor.name}',
                  style: const TextStyle(
                    color: AppAssets.white,
                    fontSize: 16, // Adjusted font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Added spacing
                Text(
                  'Character: ${actor.characterName ?? 'N/A'}',
                  style: const TextStyle(
                    color: AppAssets.white,
                    fontSize: 14, // Adjusted font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}