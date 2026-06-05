import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/app_strings.dart';
import '../models/entities/pianta.dart';
import 'widgets/plant_card.dart';

class MyPlantsScreen extends ConsumerStatefulWidget {
  const MyPlantsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends ConsumerState<MyPlantsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _paginaCorrente = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pianteProvider).caricaPiante();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linguaCtrl = ref.watch(linguaProvider);
    final pianteCtrl = ref.watch(pianteProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
            title: Text(
              AppTesti.get('btn_le_mie_piante', linguaAttuale),
              style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
            ),
          ),
          body: ValueListenableBuilder<List<Pianta>>(
            valueListenable: pianteCtrl.miePiante,
            builder: (context, listaPiante, child) {
              if (listaPiante.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.park_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      Text(
                        linguaAttuale == Lingua.it ? "Non hai ancora piante!" : "No plants yet!",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 480,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) => setState(() => _paginaCorrente = index),
                      itemCount: listaPiante.length,
                      itemBuilder: (context, index) {
                        final pianta = listaPiante[index];
                        // Animazione scale per la card attiva
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                            }
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: PlantCard(
                            pianta: pianta,
                            linguaAttuale: linguaAttuale,
                            onAnnaffia: () => pianteCtrl.innaffiaPianta(pianta),
                            onPulisci: () => pianteCtrl.pulisciPianta(pianta),
                            onElimina: () => pianteCtrl.eliminaPianta(pianta.id),
                            onCambiaPosizione: () => pianteCtrl.cambiaPosizionePianta(pianta, !pianta.isDaEsterno),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      listaPiante.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _paginaCorrente == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _paginaCorrente == index ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
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