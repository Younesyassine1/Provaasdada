import 'package:flutter/material.dart';
import '../../models/entities/pianta.dart';
import '../../core/utils/app_strings.dart';

class PlantCard extends StatelessWidget {
  final Pianta pianta;
  final Lingua linguaAttuale;
  final VoidCallback onAnnaffia;
  final VoidCallback onPulisci;
  final VoidCallback onElimina; // NUOVO: Callback per eliminare

  const PlantCard({
    Key? key,
    required this.pianta,
    required this.linguaAttuale,
    required this.onAnnaffia,
    required this.onPulisci,
    required this.onElimina,
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
          // ZONA SUPERIORE: FOTO DELLA PIANTA + BOTTONE ELIMINA
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                // Se abbiamo l'URL della foto, mostriamola, altrimenti mostriamo l'emoji
                child: pianta.immagineUrl != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Image.network(pianta.immagineUrl!, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('🌿', style: TextStyle(fontSize: 60))),
                  ),
                )
                    : const Center(child: Text('🌿', style: TextStyle(fontSize: 60))),
              ),
              // Il cestino in alto a destra
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

          // ZONA INFERIORE: TESTI E AZIONI
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pianta.nomeComune, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                Text('Specie: ${pianta.specie}', style: const TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic)),
                const SizedBox(height: 15),

                // Bottoni Azione
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: const Color(0xFF1976D2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.water_drop, size: 16),
                        label: Text(AppTesti.get('btn_annaffia', linguaAttuale)),
                        onPressed: onAnnaffia,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF3E0),
                          foregroundColor: const Color(0xFFE65100),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.cleaning_services, size: 16),
                        label: Text(AppTesti.get('btn_pulizia', linguaAttuale)),
                        onPressed: onPulisci,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}