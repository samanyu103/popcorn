class Popcorn {
  final String fromUid;
  final String toUid;
  final String tconst;
  final int timestamp;

  Popcorn({
    required this.fromUid,
    required this.toUid,
    required this.tconst,
    required this.timestamp,
  });

  factory Popcorn.fromMap(Map<String, dynamic> map) {
    return Popcorn(
      fromUid: map['fromUid'],
      toUid: map['toUid'],
      tconst: map['tconst'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'tconst': tconst,
      'timestamp': timestamp,
    };
  }
}
