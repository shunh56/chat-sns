enum DiscoveryMode {
  compatibility('相性がいい人'),
  interests('同じ趣味の人'),
  activity('今オンラインの人'),
  nearby('近くにいる人');

  const DiscoveryMode(this.displayName);
  final String displayName;
}
