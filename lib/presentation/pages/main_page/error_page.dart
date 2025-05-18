import 'package:app/core/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.e, required this.s});
  final Object e;
  final StackTrace s;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'エラーが発生しました。再起動してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: ThemeColor.text,
                    ),
              ),
              const Gap(12),
              Text(
                kDebugMode ? "error : $e\n stacktrace : $s" : "",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: ThemeColor.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
