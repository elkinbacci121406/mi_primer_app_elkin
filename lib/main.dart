import 'package:flutter/material.dart';
import 'package:mi_primer_app_elkin/features/incidentes/data/incidentes_locales.dart';
import 'package:mi_primer_app_elkin/features/incidentes/domain/incidente_vial.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Incidentes viales',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const PantallaIncidentes(),
  );
}

class PantallaIncidentes extends StatefulWidget {
  const PantallaIncidentes({super.key});

  @override
  State<PantallaIncidentes> createState() => _PantallaIncidentesState();
}

class _PantallaIncidentesState extends State<PantallaIncidentes> {
  // `late final` en el campo: el Future se crea UNA vez.
  late final Future<List<IncidenteVial>> _incidentes = IncidentesLocales()
      .obtenerTodos();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Incidentes viales')),
    body: FutureBuilder<List<IncidenteVial>>(
      future: _incidentes,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
        }

        final incidentes = snapshot.data ?? const <IncidenteVial>[];
        return ListView.separated(
          itemCount: incidentes.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final incidente = incidentes[i];
            return ListTile(
              title: Text(incidente.tipo),
              subtitle: Text(
                '${incidente.ubicacion.via} · ${incidente.estado.etiqueta}',
              ),
              trailing: incidente.tieneEvidencia
                  ? const Icon(Icons.photo_outlined)
                  : null,
            );
          },
        );
      },
    ),
  );
}
