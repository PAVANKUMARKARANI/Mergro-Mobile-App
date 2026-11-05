import 'leads_demo_data.dart';
import 'models/lead.dart';

/// The server id of the lead a demo screen points at.
///
/// Hot leads, viewings and calls are still demo data with demo ids
/// (`lead-02`); the server's seeded leads have the same names, so a demo id
/// resolves to the loaded lead with that name. Any other id is returned as
/// it is.
///
/// TODO(backend): remove once hot leads (`/api/handoffs`), viewings
/// (`/api/viewings`) and calls (`/api/calls`) carry real lead ids.
String resolveLeadId(String leadId, List<Lead>? loadedLeads) {
  if (!leadId.startsWith('lead-') || loadedLeads == null) return leadId;
  final demo = LeadsDemoData.leads(DateTime.now())
      .where((lead) => lead.id == leadId)
      .firstOrNull;
  if (demo == null) return leadId;
  final match = loadedLeads.where((lead) => lead.name == demo.name).firstOrNull;
  return match?.id ?? leadId;
}
