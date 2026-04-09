import 'package:flutter/material.dart';
import '../../repository/restaurant_repository.dart';
import 'local_push_notifications_api.dart';

class BackupProgressDialog extends StatefulWidget {
  final RestaurantRepository repository;
  final bool encryptBackup;

  const BackupProgressDialog({
    super.key, 
    required this.repository, 
    this.encryptBackup = true,
  });

  /// Displays the backup progress dialog
  static Future<void> show(BuildContext context, {required RestaurantRepository repository, bool encryptBackup = true}) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while backing up
      builder: (context) => BackupProgressDialog(
        repository: repository,
        encryptBackup: encryptBackup,
      ),
    );
  }

  @override
  State<BackupProgressDialog> createState() => _BackupProgressDialogState();
}

class _BackupProgressDialogState extends State<BackupProgressDialog> {
  double _progress = 0.0;
  String _status = "Starting backup...";
  bool _isFinished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startBackup();
  }

  Future<void> _startBackup() async {
    try {
      await widget.repository.backupDatabase(
        encryptBackup: widget.encryptBackup,
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });
            
            // Update Android Notification progress
            NotificationApi.showProgressNotification(
              id: 999, // Unique ID for backup progress
              title: "Database Backup",
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
            _error = "Backup process encountered an error.";
            _status = "Backup Failed";
          });
          NotificationApi.showNotification(
            id: 999,
            title: "Backup Failed",
            body: "An error occurred during database backup. Please check logs.",
          );
        } else {
          setState(() {
            _isFinished = true;
            _status = "Backup Completed Successfully!";
          });
          NotificationApi.showNotification(
            id: 999,
            title: "Backup Complete",
            body: "Your database backup has been saved securely.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = "Backup Failed";
        });
        
        NotificationApi.showNotification(
          id: 999,
          title: "Backup Failed",
          body: "An error occurred during database backup.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Database Backup"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48)
          else if (_isFinished)
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 48)
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
