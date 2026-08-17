import 'package:mi_primer_app_elkin/core/json.dart';

/// En qué punto de su vida está un incidente vial.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoIncidente {
  const EstadoIncidente();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoIncidente.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'reportado' => const Reportado(),
      'en_revision' => EnRevision(leerTexto(json, 'asignadoA')),
      'en_reparacion' => EnReparacion(leerFecha(json, 'inicioEn')),
      'resuelto' => Resuelto(
        leerFecha(json, 'resueltoEn'),
        leerTexto(json, 'evidencia'),
      ),
      'rechazado' => Rechazado(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Reportado() => {'tipo': 'reportado'},
    EnRevision(:final asignadoA) => {
      'tipo': 'en_revision',
      'asignadoA': asignadoA,
    },
    EnReparacion(:final inicioEn) => {
      'tipo': 'en_reparacion',
      'inicioEn': inicioEn.toIso8601String(),
    },
    Resuelto(:final resueltoEn, :final evidencia) => {
      'tipo': 'resuelto',
      'resueltoEn': resueltoEn.toIso8601String(),
      'evidencia': evidencia,
    },
    Rechazado(:final motivo) => {'tipo': 'rechazado', 'motivo': motivo},
  };

  /// Regla de negocio, no de interfaz: quién puede tocar el incidente.
  bool get sePuedeEditar => switch (this) {
    Reportado() || Rechazado() => true,
    EnRevision() || EnReparacion() || Resuelto() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    Reportado() => 'Reportado',
    EnRevision(:final asignadoA) => 'En revisión · $asignadoA',
    EnReparacion() => 'En reparación',
    Resuelto() => 'Resuelto',
    Rechazado(:final motivo) => 'Rechazado: $motivo',
  };
}

final class Reportado extends EstadoIncidente {
  const Reportado();

  @override
  bool operator ==(Object other) => other is Reportado;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Reportado()';
}

final class EnRevision extends EstadoIncidente {
  const EnRevision(this.asignadoA);

  final String asignadoA;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnRevision && other.asignadoA == asignadoA;

  @override
  int get hashCode => Object.hash(runtimeType, asignadoA);

  @override
  String toString() => 'EnRevision($asignadoA)';
}

final class EnReparacion extends EstadoIncidente {
  const EnReparacion(this.inicioEn);

  final DateTime inicioEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnReparacion && other.inicioEn == inicioEn;

  @override
  int get hashCode => Object.hash(runtimeType, inicioEn);

  @override
  String toString() => 'EnReparacion($inicioEn)';
}

final class Resuelto extends EstadoIncidente {
  const Resuelto(this.resueltoEn, this.evidencia);

  final DateTime resueltoEn;
  final String evidencia;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resuelto &&
          other.resueltoEn == resueltoEn &&
          other.evidencia == evidencia;

  @override
  int get hashCode => Object.hash(runtimeType, resueltoEn, evidencia);

  @override
  String toString() => 'Resuelto($resueltoEn, $evidencia)';
}

final class Rechazado extends EstadoIncidente {
  // El assert documenta la regla y la caza en depuración. La GARANTÍA es
  // leerTexto, que rechaza la cadena vacía también en producción.
  const Rechazado(this.motivo) : assert(motivo != '', 'rechazar exige motivo');

  final String motivo; // rechazar SIN motivo no se puede ni escribir

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Rechazado && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Rechazado($motivo)';
}
