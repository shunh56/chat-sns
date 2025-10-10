/// 足あと統計情報を表すEntity
///
/// 訪問者の数や時間帯別の分布など、集計されたデータを保持する
class FootprintStatistics {
  /// 過去24時間の訪問者数
  final int last24Hours;

  /// 過去1週間の訪問者数
  final int lastWeek;

  /// 過去1ヶ月の訪問者数
  final int lastMonth;

  /// 未読の訪問者数
  final int unseenCount;

  /// 時間帯別の訪問者分布（hour: count）
  /// 例: {9: 3, 14: 7, 20: 5} = 9時に3人、14時に7人、20時に5人
  final Map<int, int> hourlyDistribution;

  /// 頻繁な訪問者のユーザーIDリスト（上位5人）
  final List<String> frequentVisitors;

  const FootprintStatistics({
    required this.last24Hours,
    required this.lastWeek,
    required this.lastMonth,
    required this.unseenCount,
    this.hourlyDistribution = const {},
    this.frequentVisitors = const [],
  });

  /// 空の統計情報を生成（エラー時やデータがない場合のデフォルト）
  factory FootprintStatistics.empty() {
    return const FootprintStatistics(
      last24Hours: 0,
      lastWeek: 0,
      lastMonth: 0,
      unseenCount: 0,
      hourlyDistribution: {},
      frequentVisitors: [],
    );
  }

  // ビジネスロジック

  /// 新しい訪問者がいるか（未読の訪問者がいる）
  bool get hasNewVisitors => unseenCount > 0;

  /// 最近のアクティビティがあるか（過去24時間に訪問者がいる）
  bool get hasRecentActivity => last24Hours > 0;

  /// 人気があるか（過去24時間に10人以上の訪問者）
  bool get isPopular => last24Hours >= 10;

  /// ピークの時間帯を取得（最も訪問者が多い時間）
  /// データがない場合はnullを返す
  int? get peakHour {
    if (hourlyDistribution.isEmpty) return null;

    return hourlyDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 週次成長率を計算（パーセンテージ）
  /// 例: 10.5 = 先週より10.5%増加
  double get weeklyGrowthRate {
    if (lastWeek == 0) return 0;

    final dailyAverage = last24Hours.toDouble();
    final weeklyAverage = lastWeek / 7;

    return ((dailyAverage - weeklyAverage) / weeklyAverage) * 100;
  }

  /// 月次成長率を計算（パーセンテージ）
  double get monthlyGrowthRate {
    if (lastMonth == 0) return 0;

    final dailyAverage = last24Hours.toDouble();
    final monthlyAverage = lastMonth / 30;

    return ((dailyAverage - monthlyAverage) / monthlyAverage) * 100;
  }

  /// 訪問者の傾向を判定
  VisitorTrend get trend {
    if (weeklyGrowthRate > 20) return VisitorTrend.rising;
    if (weeklyGrowthRate < -20) return VisitorTrend.falling;
    return VisitorTrend.stable;
  }

  @override
  String toString() {
    return 'FootprintStatistics('
        'last24Hours: $last24Hours, '
        'lastWeek: $lastWeek, '
        'lastMonth: $lastMonth, '
        'unseenCount: $unseenCount, '
        'hasNewVisitors: $hasNewVisitors'
        ')';
  }
}

/// 訪問者の傾向
enum VisitorTrend {
  /// 増加傾向
  rising,

  /// 安定
  stable,

  /// 減少傾向
  falling,
}
