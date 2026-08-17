import 'package:mi_primer_app_elkin/features/incidentes/domain/incidente_vial.dart';

/// Lo que la aplicación necesita saber de los incidentes viales.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo.
abstract interface class IncidentesRepository {
  Future<List<IncidenteVial>> obtenerTodos();

  Future<IncidenteVial?> obtenerPorId(String id);
}
