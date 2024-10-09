// Package imports:
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ReportForm {
  final String? reason;
  final String? message;
  final String from;
  final String to;
  ReportForm({
    required this.reason,
    required this.message,
    required this.from,
    required this.to,
  });

  bool get isReady {
    return (reason != null && message != null);
  }

  toJson() {
    return {
      //
      "id": Uuid().v4(),
      "createdAt": Timestamp.now(),
      //
      "reason": reason,
      "message": message,
      "from": from,
      "to": to,
    };
  }
}

final userReportFormProvider =
    Provider.autoDispose.family<ReportForm, String>((ref, userId) {
  final reason = ref.watch(userReportFormReasonProvider);
  final message = ref.watch(userReportFormMessageProvider);
  return ReportForm(
    reason:
        reason != null ? ReportReasonConverter.convertToString(reason) : null,
    message: message,
    from: ref.watch(authProvider).currentUser!.uid,
    to: userId,
  );
});

final userReportFormReasonProvider =
    StateProvider.autoDispose<ReportReason?>((ref) => null);
final userReportFormMessageProvider =
    StateProvider.autoDispose<String?>((_) => null);
final userReportFormUserIdProvider =
    StateProvider.autoDispose<String>((ref) => "");

enum ReportReason {
  adult,
  harassment,
  dangerousAct,
  meetingPurpose,
  sexualHarassment,
  invasionOfPrivacy,
  scamOrCommercialPurpose,
  other,
}

// Project imports:

class ReportReasonConverter {
  static ReportReason fromString(String val) {
    switch (val) {
      case 'adult':
        return ReportReason.adult;
      case 'harassment':
        return ReportReason.harassment;
      case 'dangerous_act':
        return ReportReason.dangerousAct;
      case 'meeting_purpose':
        return ReportReason.meetingPurpose;
      case 'sexual_harassment':
        return ReportReason.sexualHarassment;
      case 'invasion_of_privacy':
        return ReportReason.invasionOfPrivacy;
      case 'scam_or_commercial_purpose':
        return ReportReason.scamOrCommercialPurpose;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }

  static convertToString(ReportReason reason) {
    switch (reason) {
      case ReportReason.adult:
        return "adult";
      case ReportReason.harassment:
        return "harassment";
      case ReportReason.dangerousAct:
        return "dangerous_act";
      case ReportReason.meetingPurpose:
        return "meeting_purpose";
      case ReportReason.sexualHarassment:
        return "sexual_harassment";
      case ReportReason.invasionOfPrivacy:
        return "invasion_of_privacy";
      case ReportReason.scamOrCommercialPurpose:
        return "scam_or_commercial_purpose";
      case ReportReason.other:
        return "other";
      default:
        return "other";
    }
  }

  static String toJpText(ReportReason reason) {
    switch (reason) {
      case ReportReason.adult:
        return "アダルト";
      case ReportReason.harassment:
        return "嫌がらせ行為";
      case ReportReason.dangerousAct:
        return "危険行為";
      case ReportReason.meetingPurpose:
        return "出会い目的";
      case ReportReason.sexualHarassment:
        return "セクハラ";
      case ReportReason.invasionOfPrivacy:
        return "プライバシー侵害";
      case ReportReason.scamOrCommercialPurpose:
        return "詐欺/営利目的の行為";
      case ReportReason.other:
        return "その他の違反行為";
      default:
        return "その他の違反行為";
    }
  }
}
