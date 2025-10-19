import '../../../data/truth_service.dart';
import '../../../services/faith_service.dart';

/// Integration service for TruthService in Mind Coach
class TruthIntegrationService {
  final TruthService _truthService;
  final FaithMode _faithMode;

  TruthIntegrationService(this._truthService, this._faithMode);

  /// Get reframe success message based on faith mode
  String getReframeSuccessMessage(String concept) {
    return _truthService.getReframeSuccessMessage(concept, _faithMode);
  }

  /// Get scripture for a concept (only in activated modes)
  List<Map<String, String>> getScriptureForConcept(String concept) {
    return _truthService.scripture(concept, _faithMode);
  }

  /// Get truth anchor summary for a concept
  String getTruthSummary(String concept) {
    return _truthService.summarize(concept, _faithMode);
  }

  /// Check if verse should be shown (consent-aware)
  bool shouldShowVerse() {
    if (_faithMode.isOff) return false;
    if (_faithMode == FaithMode.light) {
      // In Light mode, ask consent each session
      return true; // UI will handle consent dialog
    }
    // Disciple/Kingdom Builder modes show by default
    return true;
  }

  /// Get conversion invitation text based on context
  String getConversionInviteText(String context) {
    switch (context) {
      case 'reframe_success':
        return _faithMode.isOff 
          ? 'Want to explore how truth connects to deeper meaning?'
          : 'Truth flows from Christ. Would you like to go deeper?';
      case 'values_milestone':
        return _faithMode.isOff
          ? 'Your values aim higher than comfort. Explore the calling that outlasts you.'
          : 'Your values align with Christ\'s mission. How can you serve His kingdom?';
      case 'crisis_resolved':
        return _faithMode.isOff
          ? 'You steadied the storm. Would you like a peace that keeps watch over your mind?'
          : 'God\'s peace surpasses understanding. Rest in His strength.';
      default:
        return _faithMode.isOff
          ? 'Explore how faith can deepen your mental wellness journey.'
          : 'Continue growing in Christ\'s truth and love.';
    }
  }
}
