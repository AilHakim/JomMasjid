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

  // Later, we will add a factory method here to convert Firebase JSON data into this object
}