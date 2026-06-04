import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:psadassa/views/widgets/fiorai_button_sheet.dart';
import '../controllers/fiorai_controller.dart';
import '../controllers/language_controller.dart';
import '../core/utils/app_strings.dart';
import '../models/entities/fioraio.dart';


class FioraiScreen extends StatefulWidget {
  const FioraiScreen({Key? key}) : super(key: key);

  @override
  State<FioraiScreen> createState() => _FioraiScreenState();
}

class _FioraiScreenState extends State<FioraiScreen> {
  final LinguaController _linguaController = LinguaController();
  final FioraiController _controller = FioraiController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _controller.caricaDatiMappa().then((_) {
      if (mounted) setState(() {});
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
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        final isIt = linguaAttuale == Lingua.it;

        return Scaffold(
          appBar: AppBar(
            title: Text(isIt ? 'Fiorai Vicini' : 'Nearby Florists'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: ValueListenableBuilder<bool>(
            valueListenable: _controller.isLoading,
            builder: (context, isLoading, child) {

              if (isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      const SizedBox(height: 20),
                      Text(
                        isIt ? 'Ricerca fiorai su OpenStreetMap...' : 'Searching florists on OpenStreetMap...',
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                );
              }

              if (_controller.errore.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '${isIt ? "Si e' verificato un errore:" : "An error occurred:"}\n${_controller.errore.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final utente = _controller.posizioneAttuale!;
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
                      // Marker Utente
                      Marker(
                        point: centroMappa,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                      ),
                      // Marker Fiorai
                      ..._controller.listaFiorai.map((fioraio) {
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