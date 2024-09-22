enum AccountStatus {
  normal,
  banned,
  deleted,
  freezed,
}

class AccountStatusConverter {
  static AccountStatus convertToStatus(String? status) {
    switch (status) {
      case "normal":
        return AccountStatus.normal;
      case "banned":
        return AccountStatus.banned;
      case "deleted":
        return AccountStatus.deleted;
      case "freezed":
        return AccountStatus.freezed;
      default:
        return AccountStatus.normal;
    }
  }

  static String convertToString(AccountStatus status) {
    switch (status) {
      case AccountStatus.normal:
        return "normal";
      case AccountStatus.banned:
        return "banned";
      case AccountStatus.deleted:
        return "deleted";
      case AccountStatus.freezed:
        return "freezed";
      default:
        return "normal";
    }
  }
}
