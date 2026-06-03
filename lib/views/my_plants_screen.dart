import 'package:flutter/material.dart';
import '../controllers/piante_controller.dart';
import '../controllers/language_controller.dart';
import '../core/utils/app_strings.dart';
import '../models/entities/pianta.dart';
import 'widgets/plant_card.dart'; // Import corretto del mattoncino

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({Key? key}) : super(key: key);

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  final PianteController _controller = PianteController();
  final LinguaController _linguaController = LinguaController();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _paginaCorrente = 0;

  @override
  void initState() {
    super.initState();
    _controller.caricaPiante();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _eseguiAnnaffiatura(Pianta pianta) {
    debugPrint("UI: Richiesta annaffiatura per ${pianta.nomeComune}");
    _controller.innaffiaPianta(pianta);
  }

  void _eseguiPulizia(Pianta pianta) {
    debugPrint("UI: Richiesta pulizia per ${pianta.nomeComune}");
  }

  // NUOVO METODO: Gestisce l'eliminazione della pianta dal database
  void _eseguiEliminazione(Pianta pianta, Lingua linguaAttuale) {
    _controller.eliminaPianta(pianta.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              linguaAttuale == Lingua.it
                  ? '${pianta.nomeComune} rimossa dalla serra.'
                  : '${pianta.nomeComune} removed from the greenhouse.',
              style: const TextStyle(color: Colors.white)
          ),
          backgroundColor: Colors.red
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lingua>(
      valueListenable: _linguaController.linguaCorrente,
      builder: (context, linguaAttuale, child) {

        return Scaffold(
          backgroundColor: const Color(0xFFE0E5EC),
          body: Column(
            children: [
              _buildHeader(context, linguaAttuale),
              Expanded(child: _buildCarosello(linguaAttuale)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Lingua linguaAttuale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTesti.get('btn_le_mie_piante', linguaAttuale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                    linguaAttuale == Lingua.it ? 'La tua serra virtuale offline' : 'Your offline virtual greenhouse',
                    style: const TextStyle(fontSize: 13, color: Colors.white70)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarosello(Lingua linguaAttuale) {
    return ValueListenableBuilder<List<Pianta>>(
      valueListenable: _controller.miePiante,
      builder: (context, listaPiante, child) {
        if (listaPiante.isEmpty) {
          return Center(
            child: Text(
                linguaAttuale == Lingua.it
                    ? "Non hai ancora piante nella tua serra!"
                    : "You don't have any plants in your greenhouse yet!"
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 380, // Aumentato leggermente l'altezza per ospitare la foto comodamente
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _paginaCorrente = index),
                itemCount: listaPiante.length,
                itemBuilder: (context, index) {
                  final pianta = listaPiante[index];
                  // CORREZIONE: Usa PlantCard invece di PiantaCard
                  return PlantCard(
                    pianta: pianta,
                    linguaAttuale: linguaAttuale,
                    onAnnaffia: () => _eseguiAnnaffiatura(pianta),
                    onPulisci: () => _eseguiPulizia(pianta),
                    // CORREZIONE: Passa il metodo di eliminazione
                    onElimina: () => _eseguiEliminazione(pianta, linguaAttuale),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                listaPiante.length,
                    (index) => _buildDot(index == _paginaCorrente),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 20 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}