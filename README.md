# Incidentes viales — Valledupar

App para que ciudadanos reporten incidentes viales (huecos, semáforos dañados, cruces peligrosos) y la secretaría de movilidad les dé seguimiento hasta resolverlos.

## El dominio

- `IncidenteVial` — entidad principal. Identidad: `id`.
- `Ubicacion` — objeto de valor.
- `EstadoIncidente` — sellada: Reportado · EnRevision · EnReparacion · Resuelto · Rechazado.

Decisión: modelo escrito a mano, sin freezed, porque el mensaje de error de `CampoInvalido` es más útil para depurar que el genérico de freezed.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run