import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/hot_leads/controllers/hot_leads_controller.dart';
import 'package:mergro_ai_voice_assistant/features/hot_leads/models/handoff.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer.test();
    container.listen(hotLeadsControllerProvider, (_, _) {});
    await container.read(hotLeadsControllerProvider.future);
  });

  List<Handoff> items() => container.read(hotLeadsControllerProvider).value!;

  test('waiting handoffs come first, soonest deadline first', () {
    final list = items();
    final firstAccepted = list.indexWhere(
      (h) => h.status == HandoffStatus.accepted,
    );
    expect(
      list.skip(firstAccepted).every((h) => h.status == HandoffStatus.accepted),
      isTrue,
    );
    expect(list[0].dueAt.isBefore(list[1].dueAt), isTrue);
  });

  test('accept shows progress, then marks it accepted once', () async {
    final controller = container.read(hotLeadsControllerProvider.notifier);
    final id = items().first.id;

    final future = controller.accept(id);
    expect(items().firstWhere((h) => h.id == id).isAccepting, isTrue);
    expect(await controller.accept(id), isFalse, reason: 'already running');
    expect(await future, isTrue);

    final accepted = items().firstWhere((h) => h.id == id);
    expect(accepted.status, HandoffStatus.accepted);
    expect(accepted.acceptedAt, isNotNull);
    expect(await controller.accept(id), isFalse, reason: 'already accepted');
    expect(await controller.accept('missing'), isFalse);
  });
}
