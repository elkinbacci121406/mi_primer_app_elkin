import 'package:mi_primer_app_elkin/core/json.dart';

/// Dónde ocurrió el incidente vial.
///
/// Es un **objeto de valor**: dos ubicaciones con las mismas coordenadas son
/// la misma ubicación, así que no lleva `id` y se compara por contenido.
class Ubicacion {
  const Ubicacion({
    required this.latitud,
    required this.longitud,
    required this.via,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
    latitud: leerDecimal(json, 'latitud'),
    longitud: leerDecimal(json, 'longitud'),
    via: leerTexto(json, 'via'),
  );

  final double latitud;
  final double longitud;
  final String via;

  Map<String, dynamic> toJson() => {
    'latitud': latitud,
    'longitud': longitud,
    'via': via,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ubicacion &&
          other.latitud == latitud &&
          other.longitud == longitud &&
          other.via == via;

  @override
  int get hashCode => Object.hash(latitud, longitud, via);

  @override
  String toString() => 'Ubicacion($via, $latitud, $longitud)';
}
