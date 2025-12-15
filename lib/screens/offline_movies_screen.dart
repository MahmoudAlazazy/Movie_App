import 'package:flutter/material.dart';
import 'dart:io';
import '../models/offline_movie.dart';
import '../services/database_service.dart';
import '../services/download_manager.dart';

class OfflineMoviesScreen extends StatefulWidget {
  const OfflineMoviesScreen({super.key});

  @override
  State<OfflineMoviesScreen> createState() => _OfflineMoviesScreenState();
}

class _OfflineMoviesScreenState extends State<OfflineMoviesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final DownloadManager _downloadManager = DownloadManager();
  List<OfflineMovie> _offlineMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfflineMovies();
  }

  Future<void> _loadOfflineMovies() async {
    try {
      final movies = await _databaseService.getOfflineMovies();
      setState(() {
        _offlineMovies = movies.where((movie) => movie.isDownloaded).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading offline movies: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteMovie(OfflineMovie movie) async {
    try {
      await _downloadManager.deleteDownloadedMovie(movie.id);
      await _loadOfflineMovies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting movie: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOfflineMovies,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offlineMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No offline movies found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Download movies to watch offline',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _offlineMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _offlineMovies[index];
                    return _buildMovieCard(movie);
                  },
                ),
    );
  }

  Widget _buildMovieCard(OfflineMovie movie) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(movie.coverPath),
            width: 50,
            height: 75,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 75,
                color: Colors.grey,
                child: const Icon(Icons.movie, color: Colors.white),
              );
            },
          ),
        ),
        title: Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quality: ${movie.quality}'),
            Text('Size: ${_formatFileSize(movie.fileSize)}'),
            Text('Downloaded: ${_formatDate(movie.downloadDate)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Play'),
              onTap: () => _playMovie(movie),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _deleteMovie(movie),
            ),
          ],
        ),
      ),
    );
  }

  void _playMovie(OfflineMovie movie) {
    // TODO: Implement video player for offline movies
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing: ${movie.title}')),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.toString().length - 1) ~/ 3;
    var size = bytes / (1024 * 1024 * 1024);
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
