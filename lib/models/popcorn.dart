class Popcorn {
  final String fromUid;
  final String toUid;
  final String tconst;
  final int timestamp;
  final String? message; // <-- New optional field

  Popcorn({
    required this.fromUid,
    required this.toUid,
    required this.tconst,
    required this.timestamp,
    this.message, // <-- Optional in constructor
  });

  factory Popcorn.fromMap(Map<String, dynamic> map) {
    return Popcorn(
      fromUid: map['fromUid'],
      toUid: map['toUid'],
      tconst: map['tconst'],
      timestamp: map['timestamp'],
      message: map['message'], // <-- Will be null if not present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'tconst': tconst,
      'timestamp': timestamp,
      if (message != null) 'message': message, // <-- Store only if not null
    };
  }
}
