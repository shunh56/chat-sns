class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingPage &&
          title == other.title &&
          description == other.description &&
          imagePath == other.imagePath;

  @override
  int get hashCode => Object.hash(title, description, imagePath);
}