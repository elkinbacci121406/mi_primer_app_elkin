import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primer_app_elkin/core/json.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/estado_incidente.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/incidente_vial.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/ubicacion.dart';

IncidenteVial ejemplo({EstadoIncidente? estado, List<String>? fotos}) =>
    IncidenteVial(
      id: 'inc-001',
      tipo: 'Hueco en la vía',
      descripcion: 'Hueco de medio metro en la carrera 19.',
      ubicacion: const Ubicacion(
        latitud: 10.4631,
        longitud: -73.2532,
        via: 'Carrera 19',
      ),
      creadoEn: DateTime.utc(2026, 8, 10, 19, 5),
      estado: estado ?? const Reportado(),
      fotos: fotos ?? const <String>[],
    );

void main() {
  group('serialización', () {
    test('un incidente sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: const EnRevision('cuadrilla-2'),
        fotos: const ['https://ejemplo.co/f/1.jpg'],
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las fechas
      // y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = IncidenteVial.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('un incidente sin la clave fotos se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('fotos');
      expect(IncidenteVial.fromJson(json).fotos, isEmpty);
    });

    test('un incidente sin tipo dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('tipo');

      expect(
        () => IncidenteVial.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'tipo')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '10 de agosto';
      expect(() => IncidenteVial.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-10T19:05:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos incidentes con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos incidentes con los mismos datos comparten hashCode', () {
      // Sin esto, meterlos en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos incidentes con fotos distintas NO son iguales', () {
      expect(
        ejemplo(fotos: const ['a']),
        isNot(equals(ejemplo(fotos: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(descripcion: 'Otra descripción');

      expect(copia.descripcion, 'Otra descripción');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un incidente en revisión no se puede editar', () {
      expect(
        ejemplo(estado: const EnRevision('cuadrilla-2')).sePuedeEditar,
        isFalse,
      );
    });

    test(
      'un incidente rechazado sí se puede editar: se corrige y se reenvía',
      () {
        expect(
          ejemplo(estado: const Rechazado('faltan datos')).sePuedeEditar,
          isTrue,
        );
      },
    );

    test('un incidente de hace 20 días está vencido', () {
      final ahora = DateTime.utc(2026, 8, 30);
      expect(ejemplo().estaVencido(ahora), isTrue);
    });

    test('la etiqueta de un rechazo incluye el motivo', () {
      expect(
        const Rechazado('faltan datos').etiqueta,
        contains('faltan datos'),
      );
    });
  });
}
