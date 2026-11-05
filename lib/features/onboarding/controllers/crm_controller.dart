import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/utils/set_toggle.dart';
import '../../../shared/widgets/integration_card.dart';
import '../models/setup_drafts.dart';

/// Admin step 2 draft; kept alive so values survive Back / Next.
final crmControllerProvider = NotifierProvider<CrmController, CrmDraft>(
  CrmController.new,
);

/// Connects Zoho CRM and toggles lead sources.
class CrmController extends Notifier<CrmDraft> {
  /// Starts disconnected.
  @override
  CrmDraft build() => const CrmDraft();

  /// Connects Zoho CRM: Not connected → Connecting… → Connected.
  Future<void> connectZoho() async {
    if (state.zohoStatus != IntegrationStatus.notConnected) return;
    state = state.copyWith(zohoStatus: IntegrationStatus.connecting);

    // TODO(backend): Zoho OAuth — GET /integrations/zoho/authorize-url, open
    // it in a browser, then POST /integrations/zoho/callback {code}.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return;

    state = state.copyWith(zohoStatus: IntegrationStatus.connected);
  }

  /// Disconnects Zoho CRM.
  void disconnectZoho() {
    // TODO(backend): DELETE /integrations/zoho.
    state = state.copyWith(zohoStatus: IntegrationStatus.notConnected);
  }

  /// Turns a lead source on or off.
  void toggleLeadSource(String source) => state = state.copyWith(
    enabledLeadSources: state.enabledLeadSources.toggled(source),
  );
}
