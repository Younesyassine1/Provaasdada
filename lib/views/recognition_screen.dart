import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/network/botanica_facade.dart';
import '../controllers/piante_controller.dart';
import '../models/entities/pianta.dart';
import '../controllers/language_controller.dart';
import '../core/utils/app_strings.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({Key? key}) : super(key: key);

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  final LinguaController _linguaController = LinguaController();
  final BotanicaFacade _botanicaFacade = BotanicaFacade();
  final PianteController _pianteController = PianteController();

  File? _immagineCatturata;
  bool _isLoading = false;
  Pianta? _piantaIdentificata;
  String _messaggioStato = "";

  Future<void> _scattaFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      setState(() {
        _immagineCatturata = File(foto.path);
        _piantaIdentificata = null;
      });
      _avviaRiconoscimento();
    }
  }

  Future<void> _avviaRiconoscimento() async {
    setState(() {
      _isLoading = true;
      _messaggioStato = "Analisi PlantNet in corso...";
    });

    final nomeScientifico = await _botanicaFacade.identificaDaFoto(_immagineCatturata!);

    if (nomeScientifico != null) {
      setState(() => _messaggioStato = "Ricerca dettagli su Trefle per: $nomeScientifico...");

      final dettagli = await _botanicaFacade.ottieniDettagliDaTrefle(nomeScientifico);

      setState(() {
        _piantaIdentificata = dettagli;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _messaggioStato = "Impossibile riconoscere la pianta. Riprova con una foto più nitida.";
      });
    }
  }

  // 1. Mostra il menu dal basso per scegliere la posizione
  void _scegliPosizioneESalva(Lingua lingua) {
    if (_piantaIdentificata == null) return;
    final isIt = lingua == Lingua.it;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    isIt ? 'Dove posizionerai questa pianta?' : 'Where will you place this plant?',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50, foregroundColor: Colors.blue.shade800, padding: const EdgeInsets.symmetric(vertical: 15)),
                        icon: const Icon(Icons.home),
                        label: Text(isIt ? 'In Casa' : 'Indoor'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _eseguiSalvataggioNelDatabase(false); // isDaEsterno = false
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50, foregroundColor: Colors.green.shade800, padding: const EdgeInsets.symmetric(vertical: 15)),
                        icon: const Icon(Icons.park),
                        label: Text(isIt ? 'All\'aperto' : 'Outdoor'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _eseguiSalvataggioNelDatabase(true); // isDaEsterno = true
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );
  }

  // 2. Il salvataggio su Firebase con gestione degli errori per i doppioni
  void _eseguiSalvataggioNelDatabase(bool isEsterno) async {
    final piantaPronta = _piantaIdentificata!.copiaCon(isDaEsterno: isEsterno);

    try {
      await _pianteController.salvaPianta(piantaPronta);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pianta aggiunta alla tua Serra!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      // Se l'errore contiene la nostra frase personalizzata, sappiamo che è un doppione
      final isDoppione = e.toString().contains("già questa pianta");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDoppione
              ? '🌿 Possiedi già questa pianta nella tua serra!'
              : 'Errore Cloud: $e',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: isDoppione ? Colors.orange.shade700 : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        return Scaffold(
          backgroundColor: const Color(0xFFE0E5EC),
          appBar: AppBar(
            title: Text(linguaAttuale == Lingua.it ? 'Riconoscimento Botanico' : 'Botanical Recognition'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: _immagineCatturata == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _scattaFoto,
                          icon: const Icon(Icons.camera),
                          label: Text(linguaAttuale == Lingua.it ? 'Scatta Foto' : 'Take a Photo'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
                        )
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(_immagineCatturata!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (_isLoading) ...[
                    const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    const SizedBox(height: 15),
                    Text(_messaggioStato, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  ],

                  if (!_isLoading && _immagineCatturata != null && _piantaIdentificata == null)
                    Text(_messaggioStato, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),

                  if (_piantaIdentificata != null && !_isLoading) ...[
                    Text(
                        linguaAttuale == Lingua.it ? '🌿 Identificazione Completata!' : '🌿 Identification Complete!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))
                    ),
                    const SizedBox(height: 15),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            if (_piantaIdentificata!.immagineUrl != null) ...[
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(_piantaIdentificata!.immagineUrl!),
                                backgroundColor: const Color(0xFFE8F5E9),
                              ),
                              const SizedBox(height: 15),
                            ],

                            Text(_piantaIdentificata!.nomeComune, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            Text('Specie: ${_piantaIdentificata!.specie}', style: const TextStyle(fontStyle: FontStyle.italic)),
                            const Divider(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(children: [const Icon(Icons.water_drop, color: Colors.blue), Text(_piantaIdentificata!.fabbisognoAcqua)]),
                                Column(children: [const Icon(Icons.wb_sunny, color: Colors.orange), Text(_piantaIdentificata!.fabbisognoLuce)]),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _piantaIdentificata = null;
                                _immagineCatturata = null;
                                _messaggioStato = "";
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(linguaAttuale == Lingua.it ? 'Annulla' : 'Cancel', style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            // CAMBIATO: Ora apre il BottomSheet invece di salvare subito
                            onPressed: () => _scegliPosizioneESalva(linguaAttuale),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(linguaAttuale == Lingua.it ? 'Salva in Serra' : 'Save Plant', style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}