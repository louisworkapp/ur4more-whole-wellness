import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileSectionWidget extends StatefulWidget {
  final String fullName;
  final String timezone;
  final Function(String) onNameChanged;
  final Function(String) onTimezoneChanged;

  const ProfileSectionWidget({
    super.key,
    required this.fullName,
    required this.timezone,
    required this.onNameChanged,
    required this.onTimezoneChanged,
  });

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  final List<String> _timezones = [
    'Eastern Time (ET)',
    'Central Time (CT)',
    'Mountain Time (MT)',
    'Pacific Time (PT)',
    'Alaska Time (AKT)',
    'Hawaii Time (HT)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
      child: Padding(
        padding: Pad.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: AppSpace.x3),
                Text(
                  'Profile Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),

            // Full Name Section
            Text(
              'Full Name',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpace.x1),
            _isEditingName
                ? _buildNameEditField(theme, colorScheme)
                : _buildNameDisplay(theme, colorScheme),

            SizedBox(height: AppSpace.x3),

            // Timezone Section
            Text(
              'Timezone',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpace.x1),
            _buildTimezoneSelector(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildNameDisplay(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => setState(() => _isEditingName = true),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity( 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.fullName.isEmpty
                    ? 'Tap to add your name'
                    : widget.fullName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: widget.fullName.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'edit',
              color: colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameEditField(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
        SizedBox(width: AppSpace.x2),
        IconButton(
          onPressed: () {
            widget.onNameChanged(_nameController.text);
            setState(() => _isEditingName = false);
          },
          icon: CustomIconWidget(
            iconName: 'check',
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () {
            _nameController.text = widget.fullName;
            setState(() => _isEditingName = false);
          },
          icon: CustomIconWidget(
            iconName: 'close',
            color: colorScheme.error,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimezoneSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity( 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.timezone,
          isExpanded: true,
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          items: _timezones.map((String timezone) {
            return DropdownMenuItem<String>(
              value: timezone,
              child: Text(timezone),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              widget.onTimezoneChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
