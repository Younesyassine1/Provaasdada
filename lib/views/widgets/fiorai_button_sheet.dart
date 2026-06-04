import 'package:flutter/material.dart';
import '../../models/entities/fioraio.dart';
import '../../core/utils/app_strings.dart';

class FioraioBottomSheet extends StatelessWidget {
  final Fioraio fioraio;
  final Lingua linguaAttuale;

  const FioraioBottomSheet({Key? key, required this.fioraio, required this.linguaAttuale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIt = linguaAttuale == Lingua.it;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // NOME DEL FIORAIO
          Row(
            children: [
              const Icon(Icons.local_florist, color: Color(0xFF4CAF50), size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  fioraio.nome,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // DISTANZA
          Row(
            children: [
              const Icon(Icons.directions_walk, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Text(
                '${isIt ? "Distanza:" : "Distance:"} ${fioraio.distanzaFormattata}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // PULSANTE DI CHIUSURA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.map),
              label: Text(isIt ? 'Chiudi' : 'Close'),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}