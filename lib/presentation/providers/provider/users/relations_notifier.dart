
class RelationInfo {
  final List<String> requests;
  final List<String> requesteds;
  RelationInfo(this.requests, this.requesteds);

  factory RelationInfo.fromJson(Map<String, dynamic> json) {
    return RelationInfo(
      List<String>.from(json["requests"] ?? []),
      List<String>.from(json["requesteds"] ?? []),
    );
  }
}
