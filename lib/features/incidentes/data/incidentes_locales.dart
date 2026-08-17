import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app_elkin/core/json.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/incidente_vial.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/incidentes_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class IncidentesLocales implements IncidentesRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en las
  /// pruebas, una función que devuelve una cadena.
  IncidentesLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/incidentes.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<IncidenteVial>? _cache;

  @override
  Future<List<IncidenteVial>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => IncidenteVial.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<IncidenteVial?> obtenerPorId(String id) async {
    for (final incidente in await obtenerTodos()) {
      if (incidente.id == id) return incidente;
    }
    return null;
  }
}
