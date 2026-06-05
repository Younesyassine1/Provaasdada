// ============================================================
// FILE: fiorai_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/app_strings.dart';
import '../models/entities/fioraio.dart';
import 'widgets/fiorai_button_sheet.dart';

class FioraiScreen extends ConsumerStatefulWidget {
  const FioraiScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FioraiScreen> createState() => _FioraiScreenState();
}

class _FioraiScreenState extends ConsumerState<FioraiScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fioraiProvider).caricaDatiMappa();
    });
  }

  void _mostraInfoFioraio(Fioraio fioraio, Lingua lingua) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FioraioBottomSheet(fioraio: fioraio, linguaAttuale: lingua),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linguaCtrl = ref.watch(linguaProvider);
    final fioraiCtrl = ref.watch(fioraiProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppTesti.get('fiorai_titolo', linguaAttuale)),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: fioraiCtrl.isLoading,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      const SizedBox(height: 20),
                      Text(
                        AppTesti.get('fiorai_caricamento', linguaAttuale),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (fioraiCtrl.errore.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${AppTesti.get('err_generico', linguaAttuale)}\n${fioraiCtrl.errore.value}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => fioraiCtrl.caricaDatiMappa(),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppTesti.get('btn_riprova', linguaAttuale)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final utente = fioraiCtrl.posizioneAttuale!;
              final LatLng centroMappa = LatLng(utente.latitude, utente.longitude);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centroMappa,
                  initialZoom: 14.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.floralens',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: centroMappa,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                      ),
                      ...fioraiCtrl.listaFiorai.map((fioraio) {
                        return Marker(
                          point: LatLng(fioraio.latitudine, fioraio.longitudine),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _mostraInfoFioraio(fioraio, linguaAttuale),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}