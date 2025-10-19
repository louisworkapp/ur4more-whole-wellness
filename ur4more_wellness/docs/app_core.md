# App Core: Two Powers & Truth Axis

**Version:** 1.0  
**Date:** October 2024  
**Scope:** App-wide truth integration and faith-aware content delivery  

## Overview

The Two Powers & Truth Axis provides a unified backbone for faith-aware content across all app branches. It delivers secular-first tools while maintaining a clear evangelistic telos: guiding users toward Jesus Christ as their True North.

## Core Philosophy

### Two Powers Framework
- **Light**: God the Father, Jesus Christ, truth, order, responsibility, service
- **Darkness**: Spiritual opposition, lies, chaos, meaninglessness, selfishness
- **User Journey**: From darkness into light through evidence-based tools and faith integration

### Truth Axis Integration
Every secular concept maps to its biblical root:
- **Objective Truth** → "I am the way, the truth, and the life" (John 14:6)
- **Responsibility** → "Faith which worketh by love" (Galatians 5:6)
- **Service** → "Love thy neighbour as thyself" (Matthew 22:39)
- **Hope** → "Hope we have as an anchor of the soul" (Hebrews 6:19)

## Creed & Scripture Policy

### KJV-Only Policy
- **Version**: King James Version only for consistency
- **Length**: ≤2 sentences per excerpt
- **Accuracy**: Exact citations with proper references
- **Context**: Always include reference for verification

### Creed Structure
- **Short**: For headers and quick references
- **Hero**: For onboarding and main displays
- **Full**: Complete creed for Spirit overview
- **KJV Pack**: 5 core verses supporting the creed

## Consent-First Evangelism

### OFF Mode (Secular-First)
- Fully useful without any religious content
- Clear invitations at natural progression points
- Always provide "Keep Secular Tools" option
- Rate-limited invitations (max 1/day, 7-day snooze)

### Light Mode (Gentle Integration)
- Ask permission for verse/prayer overlays each session
- Save choice for session only (reset next session)
- Provide toggle to hide faith overlays in Mind
- Default to secular with gentle faith options

### Disciple/Kingdom Builder Modes
- Overlays on by default but always optional
- Provide toggle "hide faith overlays in Mind"
- Respect user choice immediately when toggled
- Maintain clinical quality regardless of overlay state

## TruthService Integration

### Core Service
```dart
class TruthService {
  String summarize(String concept, FaithMode mode);
  List<Map<String, String>> scripture(String concept, FaithMode mode);
  String getReframeSuccessMessage(String concept, FaithMode mode);
  String getHabitFooter(FaithMode mode);
  String getLightStreakText(FaithMode mode);
}
```

### Per-Branch Placements

#### Home Screen
- **OFF**: "Choose what leads to life" with secular guidance
- **Activated**: "Walk in the Light" with creed short + optional verse reveal

#### Mind Coach
- **Reframe Success**: "Aligned to truth" (OFF) / "Aligned to Christ's truth — John 14:6" (Activated)
- **Show Verse Button**: Reveals ≤2-sentence KJV with consent in Light mode

#### Body Fitness
- **Habit Footer**: "Choose what leads to life" (OFF) / "Present your body a living sacrifice (Rom 12:1)" (Activated)

#### Spirit Growth
- **Creed Display**: Full hero text with KJV verse carousel
- **Learn More**: Opens complete creed with scripture pack

#### Rewards
- **Light Streak**: Badge text from TruthService("Responsibility")
- **Claim Screen**: Short verse for Activated users

## Conversion Moments

### Mind-Driven Conversion
- **End of OFF weeks** → Meaning Horizon card (dual CTA)
- **High-urge resolved** → invite to Light ("Want a peace that keeps watch over your mind?")
- **Values milestone** → invite to Light when user selects service/legacy/sacrifice

### Rate Limiting
- **Maximum**: 1 invite per day
- **Snooze**: 7 days on "Not now"
- **Reset**: Weekly completion counter resets Sundays
- **Respect**: User can permanently opt out

## Content Governance

### Internal Checklists
- **Clinical**: CBT/MI/ACT compliance, crisis referral protocols
- **Theology**: KJV accuracy, doctrinal consistency, respectful tone
- **Every PR**: Both checklists must pass before merge

### Optional External Advisors
- **Clinical**: Licensed therapist for periodic review
- **Theology**: Pastor/theologian for doctrinal accuracy
- **SLA**: "When engaged" - 48h hotfix, 7d minor updates

## Implementation

### Assets
- `assets/core/creed.json` - Complete creed with KJV verses
- `assets/core/truth_anchors.json` - Concept mappings and scripture

### Services
- `TruthService` - Core truth integration service
- `CreedRepository` - Creed data loading and caching

### Widgets
- `HomeTruthCallout` - Home screen truth banner
- `VerseRevealChip` - Consent-aware verse display
- `SpiritOverview` - Complete creed and scripture display

### Integration Points
- **App Root**: Inject TruthService into all branches
- **Home**: Truth callout with mode-aware content
- **Mind**: Reframe success messages and verse reveals
- **Body**: Habit footers with truth anchors
- **Spirit**: Creed display and scripture carousel
- **Rewards**: Light streak text and claim screen verses

## Success Metrics

### Conversion Funnel
- **OFF→Light**: 10% (Phase 1) → 15%+ (Phase 2)
- **Invite Acceptance**: 6% (Phase 1) → 8-10% (Phase 2)
- **Verse Engagement**: 50%+ of Activated users view verses

### User Experience
- **OFF Mode Satisfaction**: 90%+ find tools fully useful
- **Consent Respect**: 95%+ appreciate consent model
- **Crisis Safety**: No increase in crisis incidents per DAU

### Content Quality
- **KJV Compliance**: 100% verses ≤2 sentences
- **Doctrinal Accuracy**: External theology review approval
- **Clinical Safety**: Licensed therapist sign-off

## Guardrails

### Never Coerce
- Always provide secular alternatives
- Respect user choice immediately
- Rate limit all invitations
- Allow permanent opt-out

### Always Respect
- KJV-only scripture policy
- ≤2 sentences per excerpt
- Accurate citations
- Interdenominational sensitivity

### Maintain Quality
- Clinical excellence in both modes
- Evidence-based interventions
- Crisis referral protocols
- Professional disclaimers

---

**Document Owner**: Product Team  
**Last Updated**: October 2024  
**Next Review**: November 2024  
**Approval**: Engineering, Design, Content, Data Teams
