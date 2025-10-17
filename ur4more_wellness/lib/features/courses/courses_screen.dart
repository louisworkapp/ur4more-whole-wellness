import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/tokens.dart';
import '../../services/faith_service.dart';
import 'data/course_repository.dart';
import 'models/course.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseRepository _repository = CourseRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _selectedFormats = [];
  bool _freeOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current faith tier from settings
      final faithMode = await FaithService.getFaithMode();
      final tier = _getFaithTierFromMode(faithMode.toString().split('.').last);
      
      _courses = await _repository.getCoursesForTier(tier);
      _applyFilters();
    } catch (e) {
      print('Error loading courses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  FaithTier _getFaithTierFromMode(String faithMode) {
    switch (faithMode.toLowerCase()) {
      case 'off':
        return FaithTier.off;
      case 'light':
        return FaithTier.light;
      case 'disciple':
        return FaithTier.disciple;
      case 'kingdom':
        return FaithTier.kingdomBuilder;
      default:
        return FaithTier.off;
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final matchesSearch = course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                               course.provider.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                               course.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
          if (!matchesSearch) return false;
        }

        // Format filter
        if (_selectedFormats.isNotEmpty) {
          final matchesFormat = _selectedFormats.any((format) => course.format.contains(format));
          if (!matchesFormat) return false;
        }

        // Free filter
        if (_freeOnly) {
          if (!course.cost.toLowerCase().contains('free')) return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Discipleship Courses'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: Column(
            children: [
              _buildSearchAndFilters(theme, colorScheme),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCourses.isEmpty
                        ? _buildEmptyState(theme, colorScheme)
                        : _buildCoursesList(theme, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search courses...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpace.x4,
                vertical: AppSpace.x3,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.x3),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFormats.isEmpty && !_freeOnly,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFormats.clear();
                      _freeOnly = false;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: AppSpace.x2),
                FilterChip(
                  label: const Text('Free'),
                  selected: _freeOnly,
                  onSelected: (selected) {
                    setState(() {
                      _freeOnly = selected;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: AppSpace.x2),
                FilterChip(
                  label: const Text('Video'),
                  selected: _selectedFormats.contains('video'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFormats.add('video');
                      } else {
                        _selectedFormats.remove('video');
                      }
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: AppSpace.x2),
                FilterChip(
                  label: const Text('Self-paced'),
                  selected: _selectedFormats.contains('self-paced'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFormats.add('self-paced');
                      } else {
                        _selectedFormats.remove('self-paced');
                      }
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(width: AppSpace.x2),
                FilterChip(
                  label: const Text('Group'),
                  selected: _selectedFormats.contains('group'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFormats.add('group');
                      } else {
                        _selectedFormats.remove('group');
                      }
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpace.x4),
          Text(
            'No courses found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return _buildCourseCard(course, theme, colorScheme);
      },
    );
  }

  Widget _buildCourseCard(Course course, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.x3),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and provider
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpace.x1),
                        Text(
                          course.provider,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (course.isFirstParty())
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.x2,
                        vertical: AppSpace.x1,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'In-App',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.x2),
              
              // Summary
              Text(
                course.summary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpace.x2),
              
              // Tags
              Wrap(
                spacing: AppSpace.x1,
                runSpacing: AppSpace.x1,
                children: course.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x2,
                      vertical: AppSpace.x1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpace.x3),
              
              // Bottom row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.duration,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          course.cost,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: course.cost.toLowerCase().contains('free')
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToCourse(course),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.x4,
                        vertical: AppSpace.x2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCourse(Course course) {
    if (course.isFirstParty()) {
      Navigator.pushNamed(
        context,
        '/courses/detail',
        arguments: {'courseId': course.id},
      );
    } else if (course.url.isNotEmpty) {
      _launchUrl(course.url);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
