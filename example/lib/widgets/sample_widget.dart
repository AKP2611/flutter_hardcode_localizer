import 'package:flutter/material.dart';

class SampleWidget extends StatelessWidget {
  const SampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Test: Array in local scope - READY FOR LocaleKeys.key.tr()!
    final userActions = [
      'Create New',
      'Edit Existing',
      'View Details',
      'Delete Item'
    ];

    // Test: Map with status messages - READY FOR LocaleKeys.key.tr()!
    final statusMessages = {
      'pending': 'Your request is being processed',
      'approved': 'Congratulations! Request approved',
      'rejected': 'Sorry, your request was rejected',
      'review': 'Your request is under review',
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sample Widget for easy_localization Testing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'All hardcoded strings will be converted to LocaleKeys format'),
            const SizedBox(height: 8),
            const Text(
                'JSON files will be created in assets/languages/ directory'),
            const SizedBox(height: 16),

            // Test: Dynamic UI generation from array - PERFECT FOR LOCALIZATION!
            const Text('User Actions:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: userActions
                  .map((action) => ElevatedButton.icon(
                        icon: const Icon(Icons.touch_app),
                        onPressed: () => _handleAction(context, action),
                        label: Text(action),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Test: Status indicators from map - PERFECT FOR LOCALIZATION!
            const Text('Status Messages:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Column(
              children: statusMessages.entries
                  .map((entry) => ListTile(
                        dense: true,
                        leading: Icon(_getStatusIcon(entry.key)),
                        title: Text(entry.value),
                        subtitle: Text('Status: ${entry.key.toUpperCase()}'),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),
            const Text(
              'After running the localizer, all these strings will use LocaleKeys!',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'review':
        return Icons.rate_review;
      default:
        return Icons.help;
    }
  }

  void _handleAction(BuildContext context, String action) {
    _showResult(context, 'You clicked: $action');
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
