import 'models/handoff.dart';

/// Sample handoffs shown until `GET /api/handoffs` exists.
abstract final class HotLeadsDemoData {
  /// Builds the sample handoffs relative to [now].
  static List<Handoff> handoffs(DateTime now) {
    DateTime ago(int seconds) => now.subtract(Duration(seconds: seconds));
    return [
      Handoff(
        id: 'handoff-01',
        leadId: 'lead-04',
        leadName: 'Fatima Sheikh',
        score: 88,
        area: 'Indiranagar',
        budget: '₹2 – 2.5 Cr',
        receivedAt: ago(70),
        summary:
            'Looking for a 4-bedroom villa near her office, wants to move '
            'before school starts in June. Loan pre-approved with HDFC.',
        reasons: const [
          'Pre-approved loan',
          'Moving in 60 days',
          'Budget fits',
        ],
        nextAction: 'Call back and confirm a viewing this weekend',
      ),
      Handoff(
        id: 'handoff-02',
        leadId: 'lead-02',
        leadName: 'Ananya Iyer',
        score: 91,
        area: 'Koramangala',
        budget: '₹1.2 – 1.5 Cr',
        receivedAt: ago(4 * 60 + 20),
        summary:
            'Relocating from Pune with family, needs a 3 BHK close to '
            'Koramangala 5th block. Asked to speak to an agent about parking.',
        reasons: const ['Asked for an agent', 'Ready to buy', 'Budget fits'],
        nextAction: 'Warm transfer or call back within 5 minutes',
      ),
      Handoff(
        id: 'handoff-03',
        leadId: 'lead-08',
        leadName: 'Sneha Kulkarni',
        score: 79,
        area: 'Koramangala',
        budget: '₹1 – 1.3 Cr',
        receivedAt: ago(42 * 60),
        status: HandoffStatus.accepted,
        acceptedAt: ago(40 * 60),
        summary:
            'First-time buyer, booked a viewing for today at 5 PM. Wants a '
            'west-facing flat with a balcony.',
        reasons: const ['Viewing booked', 'Timeline under 90 days'],
        nextAction: 'Meet at the viewing; share two similar listings',
      ),
    ];
  }
}
