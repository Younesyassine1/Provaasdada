// ============================================================
// FILE: plant_card.dart
// ============================================================
import 'package:flutter/material.dart';
import '../../models/entities/pianta.dart';
import '../../core/utils/app_strings.dart';
import 'bottone_azione_timer.dart';

class PlantCard extends StatelessWidget {
  final Pianta pianta;
  final Lingua linguaAttuale;
  final VoidCallback onAnnaffia;
  final VoidCallback onPulisci;
  final VoidCallback onElimina;
  final VoidCallback onCambiaPosizione;

  const PlantCard({
    Key? key,
    required this.pianta,
    required this.linguaAttuale,
    required this.onAnnaffia,
    required this.onPulisci,
    required this.onElimina,
    required this.onCambiaPosizione,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: pianta.immagineUrl != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    pianta.immagineUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('🌿', style: TextStyle(fontSize: 60))),
                  ),
                )
                    : const Center(child: Text('🌿', style: TextStyle(fontSize: 60))),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onElimina,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pianta.nomeComune,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                Text(
                  'Specie: ${pianta.specie}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                ActionChip(
                  avatar: Icon(
                    pianta.isDaEsterno ? Icons.park : Icons.home,
                    size: 16,
                    color: pianta.isDaEsterno ? Colors.green.shade800 : Colors.blue.shade800,
                  ),
                  label: Text(
                    pianta.isDaEsterno
                        ? AppTesti.get('pianta_esterno', linguaAttuale)
                        : AppTesti.get('pianta_interno', linguaAttuale),
                    style: TextStyle(
                      color: pianta.isDaEsterno ? Colors.green.shade900 : Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: pianta.isDaEsterno ? Colors.green.shade100 : Colors.blue.shade100,
                  side: BorderSide.none,
                  onPressed: onCambiaPosizione,
                  tooltip: AppTesti.get('pianta_sposta_tooltip', linguaAttuale),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: BottoneAzioneTimer(
                        pianta: pianta,
                        tipo: TipoAzione.acqua,
                        linguaAttuale: linguaAttuale,
                        onAzione: onAnnaffia,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BottoneAzioneTimer(
                        pianta: pianta,
                        tipo: TipoAzione.pulizia,
                        linguaAttuale: linguaAttuale,
                        onAzione: onPulisci,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}