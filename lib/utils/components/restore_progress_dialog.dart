import 'package:flutter/material.dart';
import '../../repository/restaurant_repository.dart';
import 'local_push_notifications_api.dart';

class RestoreProgressDialog extends StatefulWidget {
  final RestaurantRepository repository;
  final String backupFilePath;

  const RestoreProgressDialog({
    super.key,
    required this.repository,
    required this.backupFilePath,
  });

  /// Displays the restore progress dialog
  static Future<void> show(
    BuildContext context, {
    required RestaurantRepository repository,
    required String backupFilePath,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while restoring
      builder: (context) => RestoreProgressDialog(
        repository: repository,
        backupFilePath: backupFilePath,
      ),
    );
  }

  @override
  State<RestoreProgressDialog> createState() => _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends State<RestoreProgressDialog> {
  double _progress = 0.0;
  String _status = "Starting restore process...";
  bool _isFinished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startRestore();
  }

  Future<void> _startRestore() async {
    try {
      await widget.repository.restoreDatabase(
        widget.backupFilePath,
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });

            // Update Android Notification progress
            NotificationApi.showProgressNotification(
              id: 998, // Unique ID for restore progress
              title: "Database Restore",
              body: status,
              progress: (progress * 100).toInt(),
              maxProgress: 100,
            );
          }
        },
      );

      if (mounted) {
        if (_progress < 1.0) {
          // Dev mode _executeWithLogging suppresses exceptions and returns null
          // If we reached here without completing, it means an error occurred and was caught by the repository handler.
          setState(() {
            _error = "Restore process encountered an error.";
            _status = "Restore Failed";
          });
          NotificationApi.showNotification(
            id: 998,
            title: "Restore Failed",
            body:
                "An error occurred during database restore. Please check logs.",
          );
        } else {
          setState(() {
            _isFinished = true;
            _status = "Database Restored Successfully!";
            _progress = 1.0;
          });
          NotificationApi.showNotification(
            id: 998,
            title: "Restore Complete",
            body: "Your database has been restored from backup.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = "Restore Failed";
        });

        NotificationApi.showNotification(
          id: 998,
          title: "Restore Failed",
          body: "An error occurred during database restore.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Database Restore"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            )
          else if (_isFinished)
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 48,
            )
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(_status, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          if (!_isFinished && _error == null) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text("${(_progress * 100).toStringAsFixed(0)}%"),
          ],
        ],
      ),
      actions: [
        if (_isFinished || _error != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
      ],
    );
  }
}
