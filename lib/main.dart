import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const NextCueHarness());

class NextCueHarness extends StatelessWidget {
  const NextCueHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EvidencePage(),
    );
  }
}

class EvidencePage extends StatefulWidget {
  const EvidencePage({super.key});

  @override
  State<EvidencePage> createState() => _EvidencePageState();
}

class _EvidencePageState extends State<EvidencePage> {
  static const _channel = MethodChannel('app.nextcue/share-evidence');
  Map<String, Object?>? _evidence;

  @override
  void initState() {
    super.initState();
    _loadEvidence();
  }

  Future<void> _loadEvidence() async {
    Map<String, Object?>? evidence;
    try {
      evidence = await _channel.invokeMapMethod<String, Object?>(
        'getLastShareEvidence',
      );
    } on PlatformException {
      evidence = null;
    } on MissingPluginException {
      evidence = null;
    }
    if (mounted) setState(() => _evidence = evidence);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _evidence?.entries.toList();
    entries?.sort((a, b) => a.key.compareTo(b.key));
    return Scaffold(
      appBar: AppBar(title: const Text('NextCue share harness')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sanitized share evidence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectableText(
              entries == null || entries.isEmpty
                  ? 'No share evidence recorded.'
                  : entries
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .join('\n'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loadEvidence,
              child: const Text('Refresh evidence'),
            ),
          ],
        ),
      ),
    );
  }
}
