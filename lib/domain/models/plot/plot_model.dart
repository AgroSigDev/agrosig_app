class Plot {
  final int user_id;
  final int plot_id;
  final String plot_name;
  final String location;
  final double lat;
  final double long;
  final double area;
  final bool is_active;

  Plot({
    required this.user_id,
    required this.plot_id,
    required this.plot_name,
    required this.location,
    required this.lat,
    required this.long,
    required this.area,
    required this.is_active,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
    user_id: json["user_id"] ?? 0,
    plot_id: json["plot_id"] ?? 0,
    plot_name: json["plot_name"] ?? '',
    location: json["location"] ?? '',
    lat: json["lat"] != null ? double.parse(json["lat"].toString()) : 0.0,
    long: json["long"] != null ? double.parse(json["long"].toString()) : 0.0,
    area: json["area"] != null ? double.parse(json["area"].toString()) : 0.0,
    is_active: json["is_active"] ?? true,
  );

  // Método para convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() => {
    "plot_name": plot_name,
    "location": location,
    "lat": lat,
    "long": long,
    "area": area,
  };
}