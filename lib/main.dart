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
  static const _visibleKeys = <String>[
    'status',
    'pendingCount',
    'captureCount',
    'importedCount',
    'duplicateCount',
    'rejectedCount',
    'queueFailureCount',
    'repositoryFailureCount',
    'acknowledgementFailureCount',
    'optionalFailureCount',
  ];
  Map<String, Object?>? _status;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus('getImportStatus');
  }

  Future<void> _loadStatus(String method) async {
    if (mounted) setState(() => _loading = true);
    Map<String, Object?>? status;
    try {
      status = await _channel.invokeMapMethod<String, Object?>(method);
    } on PlatformException {
      status = null;
    } on MissingPluginException {
      status = null;
    }
    if (mounted) {
      setState(() {
        _status = status;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleStatus = _visibleKeys
        .where((key) => _status?.containsKey(key) ?? false)
        .map((key) => '$key: ${_status?[key]}')
        .join('\n');
    return Scaffold(
      appBar: AppBar(title: const Text('NextCue share harness')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Durable import status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectableText(
              visibleStatus.isEmpty
                  ? 'Import status unavailable.'
                  : visibleStatus,
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : () => _loadStatus('retryImport'),
              child: const Text('Retry import'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => _loadStatus('simulateOptionalFailure'),
              child: const Text('Simulate optional failure'),
            ),
          ],
        ),
      ),
    );
  }
}
