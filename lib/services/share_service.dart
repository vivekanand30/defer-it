import 'dart:async';

import 'package:share_plus/share_plus.dart';

/// Represents content shared into the app from another application.
class SharedPayload {
  SharedPayload({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

/// Listens for platform share intents and exposes them as a stream.
class ShareService {
  ShareService();

  final StreamController<SharedPayload> _controller =
      StreamController.broadcast();
  StreamSubscription<SharedMedia>? _subscription;

  Stream<SharedPayload> get stream => _controller.stream;

  Future<void> initialize() async {
    final handler = ShareHandlerPlatform.instance;
    final initial = await handler.getInitialSharedText();
    if (initial != null && initial.trim().isNotEmpty) {
      _controller.add(_payloadFromContent(initial));
    }

    _subscription = handler.sharedMediaStream.listen((SharedMedia media) {
      final content = media.content ??
          (media.attachments.isNotEmpty ? media.attachments.first.path : null);
      if (content != null) {
        _controller.add(_payloadFromContent(content));
      }
    });
  }

  SharedPayload _payloadFromContent(String content) {
    final trimmed = content.trim();
    final uri = Uri.tryParse(trimmed);
    final title = uri != null && uri.hasScheme
        ? uri.host.replaceAll('www.', '')
        : trimmed.split('\n').first;
    return SharedPayload(
        title: title.isEmpty ? 'Shared content' : title, content: trimmed);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
