import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class PrayerRequestWidget extends StatefulWidget {
  final Function(String)? onSubmit;

  const PrayerRequestWidget({
    super.key,
    this.onSubmit,
  });

  @override
  State<PrayerRequestWidget> createState() => _PrayerRequestWidgetState();
}

class _PrayerRequestWidgetState extends State<PrayerRequestWidget> {
  final TextEditingController _prayerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _prayerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme),
          if (_isExpanded) _buildExpandedContent(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: Pad.card,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpace.x2),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'favorite',
                color: AppTheme.primaryLight,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prayer Requests",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpace.x1),
                  Text(
                    "Share your heart with God",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: _isExpanded ? 'expand_less' : 'expand_more',
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpace.x4, 0, AppSpace.x4, AppSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppTheme.primaryLight
                    : colorScheme.outline.withOpacity( 0.3),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _prayerController,
              focusNode: _focusNode,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Share your prayer request or thanksgiving...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: Pad.card,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.primaryLight,
                      size: 14,
                    ),
                    SizedBox(width: AppSpace.x1),
                    Text(
                      "Private & Encrypted",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _prayerController.text.trim().isEmpty
                    ? null
                    : _submitPrayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpace.x6, vertical: AppSpace.x3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'send',
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: AppSpace.x2),
                    Text(
                      "Submit",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          _buildPrayerTips(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPrayerTips(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successLight.withOpacity( 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.successLight,
                size: 16,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                "Prayer Tips",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.successLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x1),
          Text(
            "• Be specific about your needs and concerns\n• Include gratitude for God's blessings\n• Pray for others in your community\n• Ask for wisdom and guidance",
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _submitPrayer() {
    if (_prayerController.text.trim().isNotEmpty) {
      widget.onSubmit?.call(_prayerController.text.trim());
      _prayerController.clear();
      setState(() => _isExpanded = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Prayer request submitted securely"),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
