// Flutter imports:
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Project imports:

final customRefreshHeader = CustomHeader(
  builder: (BuildContext context, RefreshStatus? status) {
    switch (status) {
      case RefreshStatus.idle:
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Center(
            child: Icon(Icons.arrow_downward_outlined),
          ),
        );
      case RefreshStatus.refreshing:
        HapticFeedback.lightImpact();
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Center(
            child: SizedBox(
              width: 32,
              child: CircularProgressIndicator(
                color: ThemeColor.stroke,
                strokeWidth: 4,
              ),
            ),
          ),
        );

      case RefreshStatus.completed:
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Center(
            child: FadeTransitionWidget(
              child: Icon(Icons.check_outlined),
            ),
          ),
        );
      case RefreshStatus.failed:
        return const Center(
          child: Text(
            "リロード中にエラーが発生しました。",
          ),
        );
      case RefreshStatus.canRefresh:
        return const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Center(
            child: Icon(Icons.arrow_upward_outlined),
          ),
        );
      default:
        return Container();
    }
  },
);

final customRefreshFooter = CustomFooter(
  builder: (BuildContext context, LoadStatus? status) {
    switch (status) {
      case LoadStatus.idle:
        return const SizedBox();
      case LoadStatus.loading:
        HapticFeedback.lightImpact();
        return const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Center(
            child: SizedBox(
              width: 32,
              child: CircularProgressIndicator(
                color: ThemeColor.stroke,
                strokeWidth: 4,
              ),
            ),
          ),
        );
      case LoadStatus.failed:
        return const Center(
          child: Text(
            "ロード中にエラーが発生しました。",
          ),
        );
      case LoadStatus.canLoading:
        return const Center(
          child: Icon(Icons.arrow_upward_outlined),
        );
      case LoadStatus.noMore:
        return const SizedBox();
      default:
        return Container();
    }
  },
);
