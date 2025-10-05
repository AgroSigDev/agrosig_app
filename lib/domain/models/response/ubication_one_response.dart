class UbicationOneResponse {

  final bool resp;
  final String msg;
  final Ubication ubication;
  //required String ubicacion,

  UbicationOneResponse({
   required this.resp,
   required this.msg,
   required this.ubication,
});

  factory UbicationOneResponse.fromJson(Map<String, dynamic> json) => UbicationOneResponse(
      resp: json["resp"],
      msg: json["msg"],
      ubication: Ubication.fromJson(json["ubication"] ?? {})
  );
}

class Ubication {

  final int id_user;
  final int id_parcela;
  final String nombre;
  final double lat;
  final double long;
  final double superficie;

  Ubication({
   required this.id_user,
   required this.id_parcela,
    required this.nombre,
   required this.lat,
   required this.long,
   required this.superficie,
});

  factory Ubication.fromJson(Map<String, dynamic> json) => Ubication(
      id_user: json["id_user"],
      id_parcela: json["id_parcela"],
      nombre: json["nombre"],
      lat: json["lat"],
      long: json["long"],
      superficie: json["superficie"],
  );
}