import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class DiscipleshipHeader extends StatelessWidget {
  const DiscipleshipHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Design system colors
    const Color _bgColor = Color(0xFF0A1428);
    const Color _surfaceColor = Color(0xFF1A2643);
    const Color _textColor = Color(0xFFFFFFFF);
    const Color _textSubColor = Color(0xFFB8C5D6);
    const Color _brandBlue = Color(0xFF4A90E2);
    const Color _brandBlue200 = Color(0xFF7BB3F0);
    const Color _brandGold = Color(0xFFFFD700);
    const Color _brandGold700 = Color(0xFFB8860B);
    const Color _outlineColor = Color(0xFF243356);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), 
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _brandBlue200.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _brandBlue200.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'auto_stories',
                  color: _brandBlue200,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discipleship Courses',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Grow deeper in your faith journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _textSubColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x3),
          Text(
            'Discover courses designed to help you follow Jesus more closely, build spiritual habits, and multiply your impact in the world.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _textSubColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
