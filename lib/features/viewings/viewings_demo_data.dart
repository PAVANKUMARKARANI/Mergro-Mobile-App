import 'models/viewing.dart';

/// Sample viewings shown until `GET /api/viewings` exists.
abstract final class ViewingsDemoData {
  /// Builds the sample viewings around [now] (today, tomorrow, this week).
  static List<Viewing> viewings(DateTime now) {
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
    return [
      Viewing(
        id: 'viewing-01',
        leadName: 'Sneha Kulkarni',
        property: '3 BHK · Prestige Lakeside',
        address: '6th Block, Koramangala',
        startsAt: at(0, 11),
        agentName: 'Arjun Mehta',
        status: ViewingStatus.completed,
      ),
      Viewing(
        id: 'viewing-02',
        leadName: 'Lakshmi Pillai',
        property: '3 BHK · Sobha Dream Acres',
        address: 'Sarjapur Road',
        startsAt: at(0, 14, 30),
        agentName: 'Neha Kapoor',
        status: ViewingStatus.noShow,
      ),
      Viewing(
        id: 'viewing-03',
        leadName: 'Sneha Kulkarni',
        property: '3 BHK · Brigade Meadows',
        address: '5th Block, Koramangala',
        startsAt: at(0, 17),
        agentName: 'Arjun Mehta',
      ),
      Viewing(
        id: 'viewing-04',
        leadName: 'Vikram Shetty',
        property: '2 BHK · Mantri Flora',
        address: 'Sector 2, HSR Layout',
        startsAt: at(1, 10, 30),
        agentName: 'Neha Kapoor',
      ),
      Viewing(
        id: 'viewing-05',
        leadName: 'Priyanka Reddy',
        property: 'Row house · Embassy Springs',
        address: 'Hebbal',
        startsAt: at(1, 16),
        agentName: 'Arjun Mehta',
        durationMinutes: 45,
        status: ViewingStatus.pending,
      ),
      Viewing(
        id: 'viewing-06',
        leadName: 'Fatima Sheikh',
        property: 'Villa · Adarsh Palm Retreat',
        address: 'Outer Ring Road, Indiranagar',
        startsAt: at(3, 11),
        agentName: 'Arjun Mehta',
        durationMinutes: 60,
      ),
    ];
  }
}
