import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/app_strings.dart';

class RecognitionScreen extends ConsumerStatefulWidget {
  const RecognitionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends ConsumerState<RecognitionScreen> {

  Future<void> _scattaFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      final botanicaCtrl = ref.read(botanicaProvider);
      final lingua = ref.read(linguaProvider).linguaCorrente.value;

      // Usiamo il controller per gestire lo stato
      botanicaCtrl.impostaImmagine(File(foto.path));
      botanicaCtrl.avviaRiconoscimento(lingua);
    }
  }

  void _scegliPosizioneESalva(Lingua linguaAttuale) {
    final botanicaCtrl = ref.read(botanicaProvider);

    if (botanicaCtrl.piantaIdentificata.value == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTesti.get('recognition_dove_pianta', linguaAttuale),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(Icons.home),
                      label: Text(AppTesti.get('recognition_in_casa', linguaAttuale)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _eseguiSalvataggioNelDatabase(false, linguaAttuale);
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      icon: const Icon(Icons.park),
                      label: Text(AppTesti.get('recognition_aperto', linguaAttuale)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _eseguiSalvataggioNelDatabase(true, linguaAttuale);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _eseguiSalvataggioNelDatabase(bool isEsterno, Lingua linguaAttuale) async {
    final botanicaCtrl = ref.read(botanicaProvider);
    final pianteCtrl = ref.read(pianteProvider);

    final piantaPronta = botanicaCtrl.piantaIdentificata.value!.copiaCon(isDaEsterno: isEsterno);

    try {
      await pianteCtrl.salvaPianta(piantaPronta);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTesti.get('succ_pianta_aggiunta', linguaAttuale),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      final isDoppione = e.toString().contains("già questa pianta");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDoppione
                ? AppTesti.get('err_pianta_doppione', linguaAttuale)
                : '${AppTesti.get('err_generico', linguaAttuale)} $e',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDoppione ? Colors.orange.shade700 : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final linguaCtrl = ref.watch(linguaProvider);
    final botanicaCtrl = ref.watch(botanicaProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        // AnimatedBuilder con Listenable.merge ci permette di ascoltare multipli
        // ValueNotifier del nostro controller senza creare un inferno di codice annidato!
        return AnimatedBuilder(
          animation: Listenable.merge([
            botanicaCtrl.isLoading,
            botanicaCtrl.immagineCatturata,
            botanicaCtrl.piantaIdentificata,
            botanicaCtrl.messaggioStato,
          ]),
          builder: (context, _) {
            // Estraiamo i valori per comodità
            final isLoading = botanicaCtrl.isLoading.value;
            final immagineCatturata = botanicaCtrl.immagineCatturata.value;
            final piantaIdentificata = botanicaCtrl.piantaIdentificata.value;
            final messaggioStato = botanicaCtrl.messaggioStato.value;

            return Scaffold(
              backgroundColor: const Color(0xFFE0E5EC),
              appBar: AppBar(
                title: Text(AppTesti.get('recognition_titolo', linguaAttuale)),
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
                        child: immagineCatturata == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _scattaFoto,
                              icon: const Icon(Icons.camera),
                              label: Text(AppTesti.get('recognition_scatta_foto', linguaAttuale)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(immagineCatturata, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (isLoading) ...[
                        const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                        const SizedBox(height: 15),
                        Text(
                          messaggioStato,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      ],

                      if (!isLoading && immagineCatturata != null && piantaIdentificata == null)
                        Text(
                          messaggioStato,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),

                      if (piantaIdentificata != null && !isLoading) ...[
                        Text(
                          AppTesti.get('recognition_completata', linguaAttuale),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                if (piantaIdentificata.immagineUrl != null) ...[
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(piantaIdentificata.immagineUrl!),
                                    backgroundColor: const Color(0xFFE8F5E9),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                                Text(
                                  piantaIdentificata.nomeComune,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'Specie: ${piantaIdentificata.specie}',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                                const Divider(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(children: [
                                      const Icon(Icons.water_drop, color: Colors.blue),
                                      Text(piantaIdentificata.fabbisognoAcqua),
                                    ]),
                                    Column(children: [
                                      const Icon(Icons.wb_sunny, color: Colors.orange),
                                      Text(piantaIdentificata.fabbisognoLuce),
                                    ]),
                                  ],
                                ),
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
                                  // Delegare la pulizia al controller
                                  botanicaCtrl.reset();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  AppTesti.get('btn_annulla', linguaAttuale),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _scegliPosizioneESalva(linguaAttuale),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  AppTesti.get('recognition_salva', linguaAttuale),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}