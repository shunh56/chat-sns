// lib/presentation/widgets/admin/sample_data_generator.dart

import 'package:app/temp/generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SampleDataGeneratorWidget extends ConsumerStatefulWidget {
  const SampleDataGeneratorWidget({Key? key}) : super(key: key);

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
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'サンプルデータ生成',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('ランダムなストーリーを50件生成します。'),
            SizedBox(height: 16),
            _isGenerating
                ? Column(
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
                          SnackBar(content: Text('50件のストーリーを生成しました')),
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
                    child: Text('サンプルストーリーを生成'),
                  ),
          ],
        ),
      ),
    );
  }
}
