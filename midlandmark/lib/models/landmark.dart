class Landmark {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final String image;
  final double score;
  final int visitCount;
  final double avgDistance;
  final bool isDeleted;

  Landmark({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.image,
    required this.score,
    required this.visitCount,
    required this.avgDistance,
    this.isDeleted = false,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    // 1. Fix the relative image path
    String rawImage = (json['image'] ?? json['image_url'] ?? '').toString();
    if (rawImage.isNotEmpty && !rawImage.startsWith('http')) {
      // Attach the base domain to the uploads folder
      rawImage = 'https://labs.anontech.info/cse489/exm3/' + rawImage;
    }

    // 2. Handle the is_active logic for soft deletes
    bool isDeletedFlag = false;
    if (json.containsKey('is_active')) {
      isDeletedFlag = json['is_active'].toString() == '0'; // If active is 0, it is deleted
    } else if (json.containsKey('is_deleted')) {
      isDeletedFlag = json['is_deleted'].toString() == '1' || json['is_deleted'] == true;
    }

    return Landmark(
      id: (json['id'] ?? json['landmark_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      lat: double.tryParse((json['lat'] ?? json['latitude'] ?? '0').toString()) ?? 0.0,
      lon: double.tryParse((json['lon'] ?? json['longitude'] ?? '0').toString()) ?? 0.0,
      image: rawImage,
      score: double.tryParse((json['score'] ?? '0').toString()) ?? 0.0,
      visitCount: int.tryParse((json['visit_count'] ?? '0').toString()) ?? 0,
      avgDistance: double.tryParse((json['avg_distance'] ?? '0').toString()) ?? 0.0,
      isDeleted: isDeletedFlag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': image,
      'score': score,
      'visit_count': visitCount,
      'avg_distance': avgDistance,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}

class Visit {
  final String id;
  final String landmarkId;
  final String landmarkName;
  final DateTime visitTime;
  final double distance;
  final bool isSynced;

  Visit({
    required this.id,
    required this.landmarkId,
    required this.landmarkName,
    required this.visitTime,
    required this.distance,
    this.isSynced = true,
  });

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'].toString(),
      landmarkId: map['landmark_id'].toString(),
      landmarkName: map['landmark_name'] ?? '',
      visitTime: DateTime.parse(map['visit_time']),
      distance: double.tryParse(map['distance'].toString()) ?? 0.0,
      isSynced: map['is_synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'landmark_id': landmarkId,
      'landmark_name': landmarkName,
      'visit_time': visitTime.toIso8601String(),
      'distance': distance,
      'is_synced': isSynced ? 1 : 0,
    };
  }
}
