class MasjidModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  MasjidModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // 1. Factory method to convert Firebase Map (JSON) into a MasjidModel object
  factory MasjidModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MasjidModel(
      id: documentId, // We pass the Firebase Document ID separately
      name: map['name'] ?? 'Unknown Masjid', // Default fallback if null
      
      // We use .toDouble() to prevent errors if Firebase accidentally saves an int (like 0 instead of 0.0)
      latitude: (map['latitude'] ?? 0.0).toDouble(), 
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  // 2. Method to convert the MasjidModel object back into a Map to save to Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      // Note: We usually don't save the 'id' inside the map itself, 
      // because Firebase already uses it as the name of the document!
    };
  }
}