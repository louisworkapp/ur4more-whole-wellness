import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_export.dart';
import '../design/tokens.dart';
import '../services/safety_monitor_service.dart';
import '../services/faith_service.dart';
import 'daily_check_in_screen/widgets/safety_alert_widget.dart';

class SafetyMonitoringScreen extends StatefulWidget {
  const SafetyMonitoringScreen({super.key});

  @override
  State<SafetyMonitoringScreen> createState() => _SafetyMonitoringScreenState();
}

class _SafetyMonitoringScreenState extends State<SafetyMonitoringScreen> {
  final TextEditingController _testTextController = TextEditingController();
  SafetyAnalysisResult? _currentAnalysis;
  bool _showAlert = false;
  FaithTier _testFaithTier = FaithTier.light;
  
  // Test data for different scenarios
  final List<Map<String, dynamic>> _testScenarios = [
    {
      'title': 'Safe Content',
      'description': 'Normal, healthy content',
      'text': 'I had a good day today. Feeling grateful for my family and friends.',
      'expectedRisk': SafetyRiskLevel.safe,
    },
    {
      'title': 'Low Risk - Mild Concerns',
      'description': 'Some concerning language but not immediate danger',
      'text': 'Feeling a bit overwhelmed lately. Sometimes I wonder if things will get better.',
      'expectedRisk': SafetyRiskLevel.low,
    },
    {
      'title': 'Medium Risk - Multiple Concerns',
      'description': 'Several concerning indicators present',
      'text': 'I feel hopeless and worthless. Nothing seems to matter anymore. I can\'t see a way out.',
      'expectedRisk': SafetyRiskLevel.medium,
    },
    {
      'title': 'High Risk - Direct Self-Harm',
      'description': 'Clear statements about self-harm or suicide',
      'text': 'I want to kill myself. I can\'t go on like this. Everyone would be better off without me.',
      'expectedRisk': SafetyRiskLevel.high,
    },
    {
      'title': 'High Risk - Threats to Others',
      'description': 'Threats or violence toward others',
      'text': 'I\'m going to hurt them. They deserve what\'s coming. This is their last warning.',
      'expectedRisk': SafetyRiskLevel.high,
    },
    {
      'title': 'High Pain Level',
      'description': 'Extremely high pain reported',
      'text': 'My pain is unbearable today. I can\'t take it anymore.',
      'expectedRisk': SafetyRiskLevel.low,
    },
  ];

  @override
  void dispose() {
    _testTextController.dispose();
    super.dispose();
  }

  void _analyzeText(String text) {
    final analysis = SafetyMonitorService.analyzeText(text);
    setState(() {
      _currentAnalysis = analysis;
      _showAlert = analysis.hasConcerns;
    });
  }

  void _testScenario(Map<String, dynamic> scenario) {
    _testTextController.text = scenario['text'] as String;
    _analyzeText(scenario['text'] as String);
  }

  void _testCheckInData() {
    final analysis = SafetyMonitorService.analyzeCheckInData(
      painLevel: 9.0, // High pain
      painRegions: ['back', 'head'],
      urgeLevel: 8.5, // High urge
      urgeTypes: ['substance_use'],
      rpeLevel: 3,
      journalText: 'I feel like giving up. The pain is too much.',
      mood: 'hopeless',
    );
    
    setState(() {
      _currentAnalysis = analysis;
      _showAlert = analysis.hasConcerns;
    });
  }

  void _dismissAlert() {
    setState(() {
      _showAlert = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Monitoring System'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Status
            _buildSystemStatusCard(theme),
            
            const SizedBox(height: 16),
            
            // Safety Alert (if active)
            if (_showAlert && _currentAnalysis != null) ...[
            SafetyAlertWidget(
              analysisResult: _currentAnalysis!,
              onDismiss: _dismissAlert,
              faithMode: _testFaithTier,
            ),
              const SizedBox(height: 16),
            ],
            
            // Faith Mode Selector
            _buildFaithTierSelectorCard(theme),
            
            const SizedBox(height: 16),
            
            // Test Scenarios
            _buildTestScenariosCard(theme),
            
            const SizedBox(height: 16),
            
            // Text Analysis Tester
            _buildTextAnalysisCard(theme),
            
            const SizedBox(height: 16),
            
            // Check-in Data Tester
            _buildCheckInTesterCard(theme),
            
            const SizedBox(height: 16),
            
            // Crisis Resources
            _buildCrisisResourcesCard(theme),
            
            const SizedBox(height: 16),
            
            // Analysis Results
            if (_currentAnalysis != null) _buildAnalysisResultsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Safety Monitoring System',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'The safety monitoring system is actively analyzing user input for signs of self-harm, suicidal ideation, or threats to others. When concerns are detected, immediate access to crisis resources is provided.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaithTierSelectorCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faith Mode Selector',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select faith mode to test spiritual support content:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FaithTier.values.map((mode) => 
                FilterChip(
                  label: Text(mode.name.toUpperCase()),
                  selected: _testFaithTier == mode,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _testFaithTier = mode;
                      });
                    }
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                ),
              ).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${_testFaithTier.name.toUpperCase()} ${_testFaithTier.isActivated ? "(Faith Active)" : "(Faith Off)"}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestScenariosCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Scenarios',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Click any scenario to test the safety detection system:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ..._testScenarios.map((scenario) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(scenario['title'] as String),
                  subtitle: Text(scenario['description'] as String),
                  trailing: Icon(
                    _getRiskIcon(scenario['expectedRisk'] as SafetyRiskLevel),
                    color: _getRiskColor(scenario['expectedRisk'] as SafetyRiskLevel),
                  ),
                  onTap: () => _testScenario(scenario),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _getRiskColor(scenario['expectedRisk'] as SafetyRiskLevel).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAnalysisCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text Analysis Tester',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _testTextController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter text to analyze for safety concerns...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _analyzeText,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _analyzeText(_testTextController.text),
                child: const Text('Analyze Text'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInTesterCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check-in Data Tester',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Test the system with high-risk check-in data:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Pain Level: 9.0/10\n• Urge Level: 8.5/10\n• Journal: "I feel like giving up. The pain is too much."\n• Mood: "hopeless"',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testCheckInData,
                child: const Text('Test High-Risk Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisResourcesCard(ThemeData theme) {
    final resources = SafetyMonitorService.getCrisisResources();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crisis Resources',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Available crisis support resources:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildResourceItem('Phone', resources['phone']!, Icons.phone, Colors.green),
            _buildResourceItem('Text', resources['text']!, Icons.sms, Colors.blue),
            _buildResourceItem('Chat', 'Crisis Chat Available', Icons.chat, Colors.orange),
            _buildResourceItem('Website', 'More Resources', Icons.language, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultsCard(ThemeData theme) {
    if (_currentAnalysis == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRiskIcon(_currentAnalysis!.riskLevel),
                  color: _getRiskColor(_currentAnalysis!.riskLevel),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Analysis Results',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(_currentAnalysis!.riskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentAnalysis!.riskLevel.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_currentAnalysis!.concerns.isNotEmpty) ...[
              Text(
                'Concerns Detected:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._currentAnalysis!.concerns.map((concern) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: _getRiskColor(_currentAnalysis!.riskLevel),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(concern)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            if (_currentAnalysis!.matchedKeywords.isNotEmpty) ...[
              Text(
                'Matched Keywords:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _currentAnalysis!.matchedKeywords.map((keyword) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRiskColor(_currentAnalysis!.riskLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRiskColor(_currentAnalysis!.riskLevel).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      keyword,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _getRiskColor(_currentAnalysis!.riskLevel),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getRiskIcon(SafetyRiskLevel riskLevel) {
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

  Color _getRiskColor(SafetyRiskLevel riskLevel) {
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
}
