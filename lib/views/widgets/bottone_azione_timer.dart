import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/entities/pianta.dart';
import '../../core/utils/app_strings.dart';

// Enumeratore per distinguere l'azione richiesta
enum TipoAzione { acqua, pulizia }

class BottoneAzioneTimer extends StatefulWidget {
  final Pianta pianta;
  final TipoAzione tipo;
  final Lingua linguaAttuale;
  final VoidCallback onAzione;

  const BottoneAzioneTimer({
    Key? key,
    required this.pianta,
    required this.tipo,
    required this.linguaAttuale,
    required this.onAzione,
  }) : super(key: key);

  @override
  State<BottoneAzioneTimer> createState() => _BottoneAzioneTimerState();
}

class _BottoneAzioneTimerState extends State<BottoneAzioneTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Il Timer ricarica solo il bottone, non l'intera card
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIt = widget.linguaAttuale == Lingua.it;
    final isAcqua = widget.tipo == TipoAzione.acqua;

    // Estrapoliamo i permessi e il tempo dal Modello
    final bool puoAgire = isAcqua ? widget.pianta.puoAnnaffiare : widget.pianta.puoPulire;
    final String tempoMancante = isAcqua
        ? widget.pianta.tempoMancanteAcqua(isIt)
        : widget.pianta.tempoMancantePulizia(isIt);

    // Testi base
    final String testoDefault = AppTesti.get(isAcqua ? 'btn_annaffia' : 'btn_pulizia', widget.linguaAttuale);

    // Colori e Icone dinamici adattati all'azione
    final IconData iconaAttiva = isAcqua ? Icons.water_drop : Icons.cleaning_services;
    final Color bgAttivo = isAcqua ? const Color(0xFFE3F2FD) : const Color(0xFFFFF3E0);
    final Color fgAttivo = isAcqua ? const Color(0xFF1976D2) : const Color(0xFFE65100);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: puoAgire ? bgAttivo : Colors.grey.shade100,
        foregroundColor: puoAgire ? fgAttivo : Colors.grey.shade500,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(puoAgire ? iconaAttiva : Icons.timer, size: 16),
      label: Text(puoAgire ? testoDefault : tempoMancante),
      onPressed: puoAgire ? widget.onAzione : null,
    );
  }
}