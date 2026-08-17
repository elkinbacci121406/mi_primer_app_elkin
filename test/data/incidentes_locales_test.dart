import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app_elkin/core/json.dart';
import 'package:mi_primer_app_elkin/features/incidentes/data/incidentes_locales.dart';

const _json = '''
[
  {
    "id": "inc-001",
    "tipo": "Hueco en la vía",
    "descripcion": "Hueco de medio metro en la carrera 19.",
    "ubicacion": { "latitud": 10.4631, "longitud": -73.2532, "via": "Carrera 19" },
    "creadoEn": "2026-08-10T19:05:00Z",
    "estado": { "tipo": "reportado" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = IncidentesLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = IncidentesLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('inc-001'))?.tipo, 'Hueco en la vía');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = IncidentesLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = IncidentesLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
    },
  );
}
