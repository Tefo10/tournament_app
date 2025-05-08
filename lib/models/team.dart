class Team {
  final String name;
  final List<String> members;

  Team({
    required this.name,
    required this.members,
  });

  @override
  String toString() => name;

  Team copyWith({
    String? name,
    List<String>? members,
  }) {
    return Team(
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }
}
