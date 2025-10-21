import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/safety_monitor_service.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class SafetyAlertWidget extends StatelessWidget {
  final SafetyAnalysisResult analysisResult;
  final VoidCallback? onDismiss;
  final String? countryCode;
  final FaithMode? faithMode;

  const SafetyAlertWidget({
    super.key,
    required this.analysisResult,
    this.onDismiss,
    this.countryCode,
    this.faithMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get crisis resources
    final resources = SafetyMonitorService.getCrisisResources(countryCode);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAlertColor(analysisResult.riskLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAlertColor(analysisResult.riskLevel),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getAlertColor(analysisResult.riskLevel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAlertIcon(analysisResult.riskLevel),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAlertTitle(analysisResult.riskLevel),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _getAlertColor(analysisResult.riskLevel),
                      ),
                    ),
                    Text(
                      _getAlertSubtitle(analysisResult.riskLevel),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _getAlertColor(analysisResult.riskLevel).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: _getAlertColor(analysisResult.riskLevel),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Concerns
          if (analysisResult.concerns.isNotEmpty) ...[
            Text(
              'We noticed:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...analysisResult.concerns.map((concern) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: _getAlertColor(analysisResult.riskLevel),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concern,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Crisis resources
          Text(
            'You are not alone. Help is available:',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Emergency call button (always shown for high risk)
          if (analysisResult.riskLevel == SafetyRiskLevel.high) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => SafetyMonitorService.launchEmergencyCall(countryCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.phone, size: 20),
                label: Text(
                  'Call ${resources['name']}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Crisis resources grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Phone
              _buildResourceButton(
                context,
                icon: Icons.phone,
                label: 'Call ${resources['phone']}',
                onTap: () => SafetyMonitorService.launchEmergencyCall(countryCode),
                color: Colors.green,
              ),
              
              // Text
              _buildResourceButton(
                context,
                icon: Icons.sms,
                label: 'Text ${resources['text']}',
                onTap: () => SafetyMonitorService.launchCrisisText(countryCode),
                color: Colors.blue,
              ),
              
              // Chat
              _buildResourceButton(
                context,
                icon: Icons.chat,
                label: 'Crisis Chat',
                onTap: () => SafetyMonitorService.launchCrisisChat(countryCode),
                color: Colors.orange,
              ),
              
              // Website
              _buildResourceButton(
                context,
                icon: Icons.language,
                label: 'More Resources',
                onTap: () => SafetyMonitorService.launchCrisisWebsite(countryCode),
                color: Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Faith-based support (if faith mode is active)
          if (faithMode?.isActivated == true) ...[
            const SizedBox(height: 16),
            _buildFaithSupportSection(context),
          ] else ...[
            // Spiritual invitation for secular users
            const SizedBox(height: 16),
            _buildSpiritualInvitationSection(context),
          ],
          
          // Additional support message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    faithMode?.isActivated == true 
                        ? 'You are loved by God and by others. Please reach out for help - you don\'t have to face this alone.'
                        : 'Your life has value. Please reach out for help - you don\'t have to face this alone.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiritualInvitationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Support Available',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Many people find comfort and strength through spiritual practices during difficult times. If you\'re open to it, we can provide:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Benefits list
          _buildBenefitItem(
            context,
            'Comforting scripture verses',
            'Words of hope and encouragement',
            Icons.menu_book,
          ),
          _buildBenefitItem(
            context,
            'Guided prayers',
            'Structured spiritual support',
            Icons.volunteer_activism,
          ),
          _buildBenefitItem(
            context,
            'Faith-based encouragement',
            'Additional perspective on your situation',
            Icons.favorite,
          ),
          
          const SizedBox(height: 16),
          
          // Invitation button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showFaithModeInvitation(context);
              },
              icon: Icon(
                Icons.explore,
                size: 18,
                color: Colors.blue.shade600,
              ),
              label: Text(
                'Explore Spiritual Support',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(
                  color: Colors.blue.shade300,
                  width: 1.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'This is completely optional - you can continue with the resources above.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.blue.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 14,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFaithModeInvitation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text('Explore Spiritual Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Would you like to enable spiritual support features? This will add:',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildDialogBenefit('Comforting Bible verses'),
            _buildDialogBenefit('Guided prayers for difficult times'),
            _buildDialogBenefit('Faith-based encouragement'),
            _buildDialogBenefit('Spiritual perspective on challenges'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You can always change this setting later in your profile.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to settings to enable faith mode
              Navigator.of(context).pushNamed('/settings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable Spiritual Support'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogBenefit(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaithSupportSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get appropriate scripture and prayer based on risk level
    final faithContent = _getFaithContentForRiskLevel(analysisResult.riskLevel);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Spiritual Support',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Scripture
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faithContent['verse'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  faithContent['reference'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Prayer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Prayer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  faithContent['prayer'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: colorScheme.onSecondaryContainer,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getFaithContentForRiskLevel(SafetyRiskLevel riskLevel) {
    switch (riskLevel) {
      case SafetyRiskLevel.safe:
        return {
          'verse': 'The Lord is my shepherd; I shall not want.',
          'reference': 'Psalm 23:1 (KJV)',
          'prayer': 'Thank you, Lord, for your constant presence and protection. Help me to trust in your guidance and find peace in your love.',
        };
      case SafetyRiskLevel.low:
        return {
          'verse': 'Cast all your anxiety on him because he cares for you.',
          'reference': '1 Peter 5:7 (KJV)',
          'prayer': 'Heavenly Father, I give you my worries and concerns. Help me to find strength in you and peace in knowing you care for me.',
        };
      case SafetyRiskLevel.medium:
        return {
          'verse': 'The Lord is close to the brokenhearted and saves those who are crushed in spirit.',
          'reference': 'Psalm 34:18 (KJV)',
          'prayer': 'Lord, I feel broken and overwhelmed. Please draw near to me and lift my spirit. Help me to feel your presence and find hope in your love.',
        };
      case SafetyRiskLevel.high:
        return {
          'verse': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, to give you hope and a future.',
          'reference': 'Jeremiah 29:11 (KJV)',
          'prayer': 'God, I\'m struggling and need your help. Please remind me of your love and your plans for my life. Give me strength to reach out for help and hope for tomorrow.',
        };
    }
  }

  Color _getAlertColor(SafetyRiskLevel riskLevel) {
    switch (riskLevel) {
      case SafetyRiskLevel.safe:
        return Colors.green;
      case SafetyRiskLevel.low:
        return Colors.orange;
      case SafetyRiskLevel.medium:
        return Colors.red;
      case SafetyRiskLevel.high:
        return Colors.red.shade800;
    }
  }

  IconData _getAlertIcon(SafetyRiskLevel riskLevel) {
    switch (riskLevel) {
      case SafetyRiskLevel.safe:
        return Icons.check_circle;
      case SafetyRiskLevel.low:
        return Icons.info;
      case SafetyRiskLevel.medium:
        return Icons.warning;
      case SafetyRiskLevel.high:
        return Icons.error;
    }
  }

  String _getAlertTitle(SafetyRiskLevel riskLevel) {
    switch (riskLevel) {
      case SafetyRiskLevel.safe:
        return 'All Good';
      case SafetyRiskLevel.low:
        return 'We Care About You';
      case SafetyRiskLevel.medium:
        return 'Support Available';
      case SafetyRiskLevel.high:
        return 'Immediate Help Available';
    }
  }

  String _getAlertSubtitle(SafetyRiskLevel riskLevel) {
    switch (riskLevel) {
      case SafetyRiskLevel.safe:
        return 'No concerns detected';
      case SafetyRiskLevel.low:
        return 'We noticed some concerning patterns';
      case SafetyRiskLevel.medium:
        return 'We\'re concerned about your wellbeing';
      case SafetyRiskLevel.high:
        return 'Please reach out for help right away';
    }
  }
}
