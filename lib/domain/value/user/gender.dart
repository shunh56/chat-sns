enum Gender {
  male,
  female,
  others,
}

class GenderConverter {
  static Gender converJPToGender(String str) {
    switch (str) {
      case "男性":
        return Gender.male;
      case "女性":
        return Gender.female;
      case "回答しない":
        return Gender.others;
      default:
        return Gender.male;
    }
  }

  static Gender convertToGender(String str) {
    switch (str) {
      case "male":
        return Gender.male;
      case "female":
        return Gender.female;
      case "others":
        return Gender.others;
      default:
        return Gender.male;
    }
  }

  static String convertToString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return "male";
      case Gender.female:
        return "female";
      case Gender.others:
        return "others";
      default:
        return "male";
    }
  }
}
