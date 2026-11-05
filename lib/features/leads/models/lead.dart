import 'package:flutter/foundation.dart';

/// Where a lead came from.
enum LeadSource {
  /// The brokerage's own website form.
  website('Website form'),

  /// Facebook / Instagram lead ads.
  facebook('Facebook Lead Ads'),

  /// Google Ads lead forms.
  googleAds('Google Ads'),

  /// 99acres portal.
  acres99('99acres'),

  /// MagicBricks portal.
  magicBricks('MagicBricks'),

  /// Housing.com portal.
  housing('Housing.com');

  /// Creates a source with its display label.
  const LeadSource(this.label);

  /// Display label.
  final String label;
}

/// Hot / Warm / Cold band of a lead score.
enum LeadTemperature {
  /// Score 75–100: hand off to an agent now.
  hot('Hot'),

  /// Score 45–74: nurture and call again.
  warm('Warm'),

  /// Score below 45: long-term nurture.
  cold('Cold');

  /// Creates a band with its label.
  const LeadTemperature(this.label);

  /// Display label.
  final String label;

  /// Band of a 1–100 [score].
  static LeadTemperature fromScore(int score) => score >= 75
      ? hot
      : score >= 45
      ? warm
      : cold;
}

/// Where a lead is in the pipeline.
enum LeadStatus {
  /// Captured, not called yet.
  newLead('New'),

  /// The AI is calling now.
  calling('AI calling'),

  /// Qualified by the AI call.
  qualified('Qualified'),

  /// A viewing is booked.
  viewingBooked('Viewing booked'),

  /// With an agent after a hot-lead handoff.
  withAgent('With agent'),

  /// In a nurture journey.
  nurturing('Nurturing'),

  /// Opted out or do-not-call: never contacted again.
  suppressed('Do not contact');

  /// Creates a status with its label.
  const LeadStatus(this.label);

  /// Display label.
  final String label;
}

/// A prospective buyer or tenant.
@immutable
class Lead {
  /// Creates a lead.
  const Lead({
    required this.id,
    required this.name,
    required this.phone,
    required this.source,
    required this.status,
    required this.area,
    required this.budget,
    required this.propertyType,
    required this.createdAt,
    required this.lastActivity,
    this.score,
    this.ownerName,
  });

  /// Stable id.
  final String id;

  /// Full name.
  final String name;

  /// Phone number, masked for display (e.g. "+91 98••• ••210").
  final String phone;

  /// Where the lead came from.
  final LeadSource source;

  /// Pipeline status.
  final LeadStatus status;

  /// Preferred area / territory.
  final String area;

  /// Budget label, e.g. "₹85 L – 1 Cr".
  final String budget;

  /// Property wanted, e.g. "3 BHK apartment".
  final String propertyType;

  /// When the lead was captured.
  final DateTime createdAt;

  /// Latest event, e.g. "AI call · qualified".
  final String lastActivity;

  /// AI score 1–100; null until the first call finishes.
  final int? score;

  /// Agent who owns the lead, if any.
  final String? ownerName;

  /// Hot / Warm / Cold band, or null when not scored yet.
  LeadTemperature? get temperature {
    final value = score;
    return value == null ? null : LeadTemperature.fromScore(value);
  }

  /// Parses a lead from `GET /api/leads` or `/api/leads/:id`. Throws
  /// [FormatException] when the id, name, source, status or date is missing
  /// or unknown.
  factory Lead.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final name = json['name'];
    final source = LeadSource.values.asNameMap()[json['source']];
    final status = LeadStatus.values.asNameMap()[json['status']];
    final createdAt = DateTime.tryParse('${json['createdAt']}');
    if (id is! String ||
        name is! String ||
        source == null ||
        status == null ||
        createdAt == null) {
      throw const FormatException('Invalid lead in API response');
    }
    String text(String key) => json[key] is String ? json[key] as String : '';
    final score = json['score'];
    final owner = json['ownerName'];
    return Lead(
      id: id,
      name: name,
      phone: text('phone'),
      source: source,
      status: status,
      area: text('area'),
      budget: text('budget'),
      propertyType: text('propertyType'),
      createdAt: createdAt.toLocal(),
      lastActivity: text('lastActivity'),
      score: score is num ? score.round() : null,
      ownerName: owner is String && owner.isNotEmpty ? owner : null,
    );
  }

  /// Copies with a new [status] and [lastActivity].
  Lead copyWith({LeadStatus? status, String? lastActivity}) {
    return Lead(
      id: id,
      name: name,
      phone: phone,
      source: source,
      status: status ?? this.status,
      area: area,
      budget: budget,
      propertyType: propertyType,
      createdAt: createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      score: score,
      ownerName: ownerName,
    );
  }
}
