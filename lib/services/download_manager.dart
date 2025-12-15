import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/movie.dart';
import '../models/offline_movie.dart';
import 'database_service.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio();
  final DatabaseService _databaseService = DatabaseService();
  final Map<int, double> _downloadProgress = {};
  final Map<int, CancelToken> _cancelTokens = {};

  // Request storage permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        return false;
      }
      
      if (Platform.isAndroid && (await Permission.manageExternalStorage.isDenied)) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }
    }
    return true;
  }

  // Get download directory
  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download/MoviesApp');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  // Download movie
  Future<void> downloadMovie(Movie movie, String quality) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final downloadDir = await getDownloadDirectory();
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Find the torrent with selected quality
      final torrent = movie.torrents.firstWhere(
        (t) => t.quality == quality,
        orElse: () => movie.torrents.first,
      );

      final fileName = '${movie.title}_$quality.mp4';
      final filePath = '${downloadDir.path}/$fileName';

      // Download cover image
      final coverFile = await DefaultCacheManager().getSingleFile(movie.mediumCoverImage);
      final coverPath = '${downloadDir.path}/cover_${movie.id}.jpg';
      await coverFile.copy(coverPath);

      // Create offline movie entry
      final offlineMovie = OfflineMovie(
        id: movie.id,
        title: movie.title,
        titleEnglish: movie.titleEnglish,
        filePath: filePath,
        coverPath: coverPath,
        quality: quality,
        fileSize: torrent.sizeBytes,
        downloadDate: DateTime.now(),
        isDownloaded: false,
        rating: movie.rating,
        runtime: movie.runtime,
        genres: movie.genres,
        summary: movie.summary,
        language: movie.language,
        backgroundImage: movie.backgroundImage,
      );

      await _databaseService.insertOfflineMovie(offlineMovie);

      // Start download
      final cancelToken = CancelToken();
      _cancelTokens[movie.id] = cancelToken;

      await _dio.download(
        torrent.url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[movie.id] = received / total;
          }
        },
      );

      // Update download status
      await _databaseService.updateDownloadStatus(movie.id, true);
      _downloadProgress.remove(movie.id);
      _cancelTokens.remove(movie.id);

    } catch (e) {
      _downloadProgress.remove(movie.id);
      _cancelTokens.remove(movie.id);
      rethrow;
    }
  }

  // Get download progress
  Stream<double> getDownloadProgress(int movieId) {
    return Stream.periodic(Duration(milliseconds: 100), (_) {
      return _downloadProgress[movieId] ?? 0.0;
    });
  }

  // Cancel download
  void cancelDownload(int movieId) {
    _cancelTokens[movieId]?.cancel();
    _cancelTokens.remove(movieId);
    _downloadProgress.remove(movieId);
  }

  // Check if movie is downloading
  bool isDownloading(int movieId) {
    return _downloadProgress.containsKey(movieId);
  }

  // Get download progress value
  double? getProgress(int movieId) {
    return _downloadProgress[movieId];
  }

  // Delete downloaded movie
  Future<void> deleteDownloadedMovie(int movieId) async {
    try {
      final offlineMovie = await _databaseService.getOfflineMovie(movieId);
      if (offlineMovie != null) {
        final file = File(offlineMovie.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        
        final coverFile = File(offlineMovie.coverPath);
        if (await coverFile.exists()) {
          await coverFile.delete();
        }
        
        await _databaseService.deleteOfflineMovie(movieId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get available storage space
  Future<int> getAvailableStorage() async {
    try {
      final directory = await getDownloadDirectory();
      final stat = await directory.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }
}
