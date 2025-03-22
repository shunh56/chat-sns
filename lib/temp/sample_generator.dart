// lib/presentation/widgets/admin/sample_data_generator.dart

import 'package:app/temp/generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SampleDataGeneratorWidget extends ConsumerStatefulWidget {
  const SampleDataGeneratorWidget({super.key});

  @override
  ConsumerState<SampleDataGeneratorWidget> createState() =>
      _SampleDataGeneratorWidgetState();
}

class _SampleDataGeneratorWidgetState
    extends ConsumerState<SampleDataGeneratorWidget> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'サンプルデータ生成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('ランダムなストーリーを50件生成します。'),
            const SizedBox(height: 16),
            _isGenerating
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('生成中...'),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isGenerating = true;
                      });

                      try {
                        await generateSampleStories(ref);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('50件のストーリーを生成しました')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('エラーが発生しました: $e')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isGenerating = false;
                          });
                        }
                      }
                    },
                    child: const Text('サンプルストーリーを生成'),
                  ),
          ],
        ),
      ),
    );
  }
}
