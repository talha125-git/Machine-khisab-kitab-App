import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ServerSettingsDialog extends StatefulWidget {
  final VoidCallback? onSaved;

  const ServerSettingsDialog({super.key, this.onSaved});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  void _loadUrl() async {
    final currentUrl = await ApiService.getBaseUrl();
    _urlController.text = currentUrl;
    setState(() {
      _isLoading = false;
    });
  }

  void _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final tempUrl = _urlController.text.trim();
    await ApiService.setBaseUrl(tempUrl);
    final ok = await ApiService.checkHealth();

    setState(() {
      _isTesting = false;
      _testSuccess = ok;
      _testResult = ok
          ? 'Connected successfully to backend!'
          : 'Failed to connect. Make sure backend is running.';
    });
  }

  void _save() async {
    await ApiService.setBaseUrl(_urlController.text.trim());
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend server URL saved.')),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF131D33),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _isLoading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dns_rounded, color: AppTheme.accentCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Server Configuration',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Specify the Machine War Data backend URL (Node/Express API):',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'http://localhost:5000',
                      prefixIcon: Icon(Icons.link_rounded, size: 18, color: AppTheme.textSubtle),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('localhost:5000', style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFF1E293B),
                        onPressed: () {
                          _urlController.text = 'http://localhost:5000';
                        },
                      ),
                      ActionChip(
                        label: const Text('10.0.2.2:5000 (Android)', style: TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFF1E293B),
                        onPressed: () {
                          _urlController.text = 'http://10.0.2.2:5000';
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_testResult != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _testSuccess
                            ? AppTheme.emeraldGreen.withValues(alpha: 0.15)
                            : AppTheme.dangerRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _testSuccess
                              ? AppTheme.emeraldGreen.withValues(alpha: 0.4)
                              : AppTheme.dangerRed.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                            size: 16,
                            color: _testSuccess ? AppTheme.emeraldGreen : AppTheme.dangerRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testResult!,
                              style: TextStyle(
                                fontSize: 12,
                                color: _testSuccess ? AppTheme.emeraldGreen : AppTheme.dangerRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isTesting ? null : _testConnection,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.network_check_rounded, size: 16),
                        label: const Text('Test'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
