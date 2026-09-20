import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_reset.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, dynamic>? _storageInfo;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final info = await AppReset.getStorageInfo();
    setState(() {
      _storageInfo = info;
    });
  }

  Future<void> _performReset(String type) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Performing $type reset...';
    });

    try {
      switch (type) {
        case 'complete':
          await AppReset.resetAppForProduction();
          _statusMessage = '✅ Complete app reset successful!\n🚀 Ready for App Store';
          break;
        case 'missions':
          await AppReset.resetMissionsOnly();
          _statusMessage = '✅ Mission data reset successful!';
          break;
        case 'scores':
          await AppReset.resetScoresOnly();
          _statusMessage = '✅ Scores and statistics reset successful!';
          break;
        case 'profile':
          await AppReset.resetProfileOnly();
          _statusMessage = '✅ User profile reset successful!';
          break;
      }

      // Reload storage info after reset
      await _loadStorageInfo();
      
    } catch (e) {
      _statusMessage = '❌ Reset failed: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Debug Panel',
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅') 
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage.contains('✅') 
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Storage Info
            _buildStorageInfoCard(),
            
            const SizedBox(height: 30),

            // Reset Buttons
            Text(
              'Reset Options',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            _buildResetButton(
              title: '🚀 Complete Reset (Production Ready)',
              subtitle: 'Clear ALL data - Ready for App Store',
              color: Colors.red,
              onTap: () => _showConfirmDialog('complete'),
            ),
            
            const SizedBox(height: 12),
            
            _buildResetButton(
              title: '🎯 Reset Missions Only',
              subtitle: 'Clear daily missions and progress',
              color: Colors.orange,
              onTap: () => _performReset('missions'),
            ),
            
            const SizedBox(height: 12),
            
            _buildResetButton(
              title: '🏆 Reset Scores Only',
              subtitle: 'Clear all game scores and statistics',
              color: Colors.blue,
              onTap: () => _performReset('scores'),
            ),
            
            const SizedBox(height: 12),
            
            _buildResetButton(
              title: '👤 Reset Profile Only',
              subtitle: 'Clear user profile and settings',
              color: Colors.purple,
              onTap: () => _performReset('profile'),
            ),

            const SizedBox(height: 30),

            // Refresh Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _loadStorageInfo,
              child: Text(
                'Refresh Storage Info',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard() {
    if (_storageInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Information',
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Total Keys', '${_storageInfo!['total_keys']}'),
          _buildInfoRow('Mission Keys', '${(_storageInfo!['mission_keys'] as List).length}'),
          _buildInfoRow('Score Keys', '${(_storageInfo!['score_keys'] as List).length}'),
          _buildInfoRow('Profile Keys', '${(_storageInfo!['profile_keys'] as List).length}'),
          _buildInfoRow('Other Keys', '${(_storageInfo!['other_keys'] as List).length}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(String resetType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A3E),
          title: Text(
            '⚠️ Complete Reset',
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This will permanently delete ALL app data including:\n\n'
            '• All game scores and statistics\n'
            '• Daily missions and progress\n'
            '• User profile and settings\n'
            '• All preferences and saved data\n\n'
            'This action cannot be undone!\n\n'
            'Are you sure you want to proceed?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _performReset(resetType);
              },
              child: Text(
                'Reset Everything',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
