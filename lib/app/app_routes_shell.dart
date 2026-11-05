part of 'app_routes.dart';

/// Navigation inside the signed-in app shell (screens 4–11). Part of
/// [AppRoutes] so all navigation stays in one library.
abstract final class _ShellRoutes {
  /// Root screen of [tab]. In the bar it has no back button; pushed from
  /// "More" or a dashboard link it gets one automatically.
  static Widget tabRoot(
    BuildContext context,
    AppTab tab,
    VoidCallback onSignOut,
  ) {
    void open(AppTab target) => openTab(context, target, onSignOut);
    void openLead(String leadId) => openLeadProfile(context, leadId);
    void openCall(String callId) => openLiveCall(context, callId);
    return switch (tab) {
      AppTab.home => HomeScreen(
        onOpenTab: open,
        onOpenLead: openLead,
        onOpenCall: openCall,
      ),
      AppTab.leads => LeadsScreen(
        onOpenFilters: () => showLeadFilters(context),
        onOpenLead: openLead,
      ),
      AppTab.liveCalls => LiveCallsScreen(onOpenCall: openCall),
      AppTab.hotLeads => HotLeadsScreen(onOpenLead: openLead),
      AppTab.viewings => ViewingsScreen(onOpenLead: openLead),
      AppTab.nurture => const NurtureScreen(),
      AppTab.profile => ProfileScreen(onSignOut: onSignOut),
      AppTab.more => MoreScreen(onOpenTab: open),
    };
  }

  /// Switches to [tab] when it is in the bar; otherwise pushes it as its
  /// own screen.
  static void openTab(
    BuildContext context,
    AppTab tab,
    VoidCallback onSignOut,
  ) {
    final container = ProviderScope.containerOf(context, listen: false);
    if (container.read(appShellControllerProvider.notifier).select(tab)) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pushedContext) => tabRoot(pushedContext, tab, onSignOut),
      ),
    );
  }

  /// Pushes the lead profile (screen 13) for [leadId].
  static void openLeadProfile(BuildContext context, String leadId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (profileContext) => LeadProfileScreen(
          leadId: leadId,
          onComposeMessage: () => showSendMessage(profileContext, leadId),
          onBookViewing: () => openBookViewing(profileContext, leadId),
          onOpenCall: (callId) => openCallDetail(profileContext, callId),
        ),
      ),
    );
  }

  /// Pushes the live call monitor (screen 12) for [callId].
  static void openLiveCall(BuildContext context, String callId) {
    _push(
      context,
      (monitorContext) => LiveCallMonitorScreen(
        callId: callId,
        onOpenLead: (leadId) => openLeadProfile(monitorContext, leadId),
      ),
    );
  }

  /// Pushes a finished call's detail (screen 14).
  static void openCallDetail(BuildContext context, String callId) {
    _push(
      context,
      (detailContext) => CallDetailScreen(
        callId: callId,
        onOpenTranscript: () =>
            _push(detailContext, (_) => TranscriptScreen(callId: callId)),
      ),
    );
  }

  /// Pushes Book viewing (screen 18); on success returns to the profile
  /// and confirms there.
  static void openBookViewing(BuildContext context, String leadId) {
    _push(
      context,
      (bookingContext) => BookViewingScreen(
        leadId: leadId,
        onBooked: (message) {
          Navigator.of(bookingContext).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
      ),
    );
  }

  /// Pushes a screen built by [builder].
  static void _push(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  /// Message composer sheet; closes and confirms once sent.
  static void showSendMessage(BuildContext context, String leadId) {
    AppRoutes._showSheet<void>(
      context,
      (sheetContext) => SendMessageSheet(
        leadId: leadId,
        onSent: (message) {
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
      ),
    );
  }

  /// Lead search filters (screen 11) as a bottom sheet.
  static void showLeadFilters(BuildContext context) {
    AppRoutes._showSheet<void>(
      context,
      (sheetContext) =>
          LeadFilterSheet(onDone: () => Navigator.of(sheetContext).pop()),
    );
  }
}
