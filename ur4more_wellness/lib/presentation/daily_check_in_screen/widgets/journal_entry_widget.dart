import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class JournalEntryWidget extends StatefulWidget {
  final String journalText;
  final String selectedMood;
  final List<String> attachedPhotos;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onMoodChanged;
  final ValueChanged<List<String>> onPhotosChanged;

  const JournalEntryWidget({
    super.key,
    required this.journalText,
    required this.selectedMood,
    required this.attachedPhotos,
    required this.onTextChanged,
    required this.onMoodChanged,
    required this.onPhotosChanged,
  });

  @override
  State<JournalEntryWidget> createState() => _JournalEntryWidgetState();
}

class _JournalEntryWidgetState extends State<JournalEntryWidget> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Grateful', 'icon': 'favorite', 'color': Colors.pink},
    {'name': 'Peaceful', 'icon': 'self_improvement', 'color': Colors.blue},
    {'name': 'Energetic', 'icon': 'bolt', 'color': Colors.orange},
    {'name': 'Hopeful', 'icon': 'wb_sunny', 'color': Colors.amber},
    {'name': 'Reflective', 'icon': 'psychology', 'color': Colors.purple},
    {'name': 'Challenged', 'icon': 'fitness_center', 'color': Colors.red},
    {'name': 'Content', 'icon': 'sentiment_satisfied', 'color': Colors.green},
    {'name': 'Anxious', 'icon': 'sentiment_dissatisfied', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.journalText;
    _textController.addListener(() {
      widget.onTextChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos'),
          ),
        );
      }
    }
  }

  Future<void> _addPhoto() async {
    await _requestCameraPermission();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (photo != null) {
                  final updatedPhotos =
                      List<String>.from(widget.attachedPhotos);
                  updatedPhotos.add(photo.path);
                  widget.onPhotosChanged(updatedPhotos);
                }
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (photo != null) {
                  final updatedPhotos =
                      List<String>.from(widget.attachedPhotos);
                  updatedPhotos.add(photo.path);
                  widget.onPhotosChanged(updatedPhotos);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    final updatedPhotos = List<String>.from(widget.attachedPhotos);
    updatedPhotos.removeAt(index);
    widget.onPhotosChanged(updatedPhotos);
  }

  // Calculate journal points - +10 if text length ≥ 120 chars
  int _calculateJournalPoints() {
    return widget.journalText.trim().length >= 120 ? 10 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalPoints = _calculateJournalPoints();
    final characterCount = widget.journalText.length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points indicator (only if qualifying)
          if (journalPoints > 0) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1), // Gold accent
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'stars',
                    color: Colors.amber.shade700, // Gold color
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '+$journalPoints points (detailed entry)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Mood Selection - "How are you feeling today?" chips
          Text(
            'How are you feeling today?',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Mood chips in horizontal scroll
          SizedBox(
            height: 8.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = widget.selectedMood == mood['name'];

                return GestureDetector(
                  onTap: () => widget.onMoodChanged(
                    isSelected ? '' : mood['name'],
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (mood['color'] as Color).withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (mood['color'] as Color)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: mood['icon'],
                          color: isSelected
                              ? (mood['color'] as Color)
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          mood['name'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? (mood['color'] as Color)
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Journal Text Input with character counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Write about your day',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              // Character counter (e.g., "0/500")
              Text(
                '$characterCount/500',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: characterCount >= 120
                      ? Colors.amber.shade700 // Gold when qualifying for bonus
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      characterCount >= 120 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          TextField(
            controller: _textController,
            maxLines: 6,
            maxLength: 500,
            decoration: InputDecoration(
              hintText:
                  'Share your thoughts, feelings, challenges, victories, or anything on your mind...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              counterText: '', // Hide default counter since we have custom one
            ),
          ),

          SizedBox(height: 3.h),

          // Photo Attachments - "Add Photo" option
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Photo (Optional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: _addPhoto,
                icon: CustomIconWidget(
                  iconName: 'add_a_photo',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Add Photo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Display attached photos
          if (widget.attachedPhotos.isNotEmpty) ...[
            SizedBox(height: 2.h),
            SizedBox(
              height: 15.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.attachedPhotos.length,
                separatorBuilder: (context, index) => SizedBox(width: 2.w),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 20.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: widget.attachedPhotos[index],
                            width: 20.w,
                            height: 15.h,
                            fit: BoxFit.cover,
                            semanticLabel:
                                "Progress photo ${index + 1} attached to journal entry",
                          ),
                        ),
                      ),
                      Positioned(
                        top: 1.w,
                        right: 1.w,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          // Bonus points explanation
          if (characterCount < 120) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Write at least 120 characters for +10 bonus points.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
