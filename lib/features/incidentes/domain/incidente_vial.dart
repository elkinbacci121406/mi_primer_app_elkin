import 'package:mi_primer_app_elkin/core/comparaciones.dart';
import 'package:mi_primer_app_elkin/core/json.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/estado_incidente.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/ubicacion.dart';

/// Un incidente vial reportado por un ciudadano.
///
/// Es una **entidad**: tiene identidad propia. Dos incidentes con el mismo
/// texto son dos incidentes distintos si tienen `id` distinto.
class IncidenteVial {
  const IncidenteVial({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.ubicacion,
    required this.creadoEn,
    required this.estado,
    this.fotos = const <String>[],
  });

  factory IncidenteVial.fromJson(Map<String, dynamic> json) => IncidenteVial(
    id: leerTexto(json, 'id'),
    tipo: leerTexto(json, 'tipo'),
    descripcion: leerTexto(json, 'descripcion'),
    ubicacion: Ubicacion.fromJson(leerMapa(json, 'ubicacion')),
    creadoEn: leerFecha(json, 'creadoEn'),
    estado: EstadoIncidente.fromJson(leerMapa(json, 'estado')),
    fotos: leerTextos(json, 'fotos'),
  );

  final String id;
  final String tipo;
  final String descripcion;
  final Ubicacion ubicacion;
  final DateTime creadoEn;
  final EstadoIncidente estado;
  final List<String> fotos;

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo': tipo,
    'descripcion': descripcion,
    'ubicacion': ubicacion.toJson(),
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    'fotos': fotos,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────
  // Viven aquí, no en el widget. Un widget no se puede probar en 3 ms.

  bool get tieneEvidencia => fotos.isNotEmpty;

  bool get sePuedeEditar => estado.sePuedeEditar;

  /// El reloj entra como parámetro, no se lee dentro.
  ///
  /// Con `DateTime.now()` dentro, esta regla no se puede probar: el resultado
  /// depende del día en que se corra la prueba.
  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  bool estaVencido(DateTime ahora) =>
      antiguedad(ahora) > const Duration(days: 15);

  // ── Copia ───────────────────────────────────────────────────────────────

  IncidenteVial copyWith({
    String? tipo,
    String? descripcion,
    Ubicacion? ubicacion,
    EstadoIncidente? estado,
    List<String>? fotos,
  }) => IncidenteVial(
    id: id, // la identidad NO se copia con cambios
    tipo: tipo ?? this.tipo,
    descripcion: descripcion ?? this.descripcion,
    ubicacion: ubicacion ?? this.ubicacion,
    creadoEn: creadoEn, // ni la fecha de creación
    estado: estado ?? this.estado,
    fotos: fotos ?? this.fotos,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidenteVial &&
          other.id == id &&
          other.tipo == tipo &&
          other.descripcion == descripcion &&
          other.ubicacion == ubicacion &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          listasIguales(other.fotos, fotos);

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    descripcion,
    ubicacion,
    creadoEn,
    estado,
    Object.hashAll(fotos), // NO Object.hash(fotos): eso hashea la referencia
  );

  @override
  String toString() => 'IncidenteVial($id, $tipo, ${estado.etiqueta})';
}
