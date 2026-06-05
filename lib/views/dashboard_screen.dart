import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_providers.dart';
import '../core/utils/app_strings.dart';
import 'widgets/menu_button.dart';
import 'widgets/meteo_banner.dart';
import 'recognition_screen.dart';
import 'my_plants_screen.dart';
import 'fiorai_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linguaCtrl = ref.watch(linguaProvider);
    final authCtrl = ref.watch(authProvider);

    return ValueListenableBuilder<Lingua>(
      valueListenable: linguaCtrl.linguaCorrente,
      builder: (context, linguaAttuale, child) {
        final isIt = linguaAttuale == Lingua.it;
        final primoNome = authCtrl.ottieniNomeFormattato(isIt);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    isIt ? 'Ciao, $primoNome! 🌿' : 'Hi, $primoNome! 🌿',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?q=80&w=800&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                      Container(color: Colors.black.withOpacity(0.4)),
                    ],
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => linguaCtrl.toggleLingua(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Center(child: Text(isIt ? '🇮🇹' : '🇬🇧', style: const TextStyle(fontSize: 24))),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MeteoBanner(linguaAttuale: linguaAttuale),
                      const SizedBox(height: 20),
                      MenuButton(
                        icona: Icons.document_scanner_rounded,
                        coloreBg: Colors.green.shade100,
                        coloreIcona: Colors.green.shade800,
                        titolo: isIt ? 'Riconoscimento' : 'Recognition',
                        sottotitolo: isIt ? 'Identifica una pianta con AI' : 'Identify a plant with AI',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecognitionScreen())),
                      ),
                      const SizedBox(height: 15),
                      MenuButton(
                        icona: Icons.map_rounded,
                        coloreBg: Colors.blue.shade100,
                        coloreIcona: Colors.blue.shade800,
                        titolo: isIt ? 'Trova Fioraio' : 'Find Florist',
                        sottotitolo: isIt ? 'Esplora vivai vicini' : 'Explore nearby nurseries',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FioraiScreen())),
                      ),
                      const SizedBox(height: 15),
                      MenuButton(
                        icona: Icons.local_florist_rounded,
                        coloreBg: Colors.orange.shade100,
                        coloreIcona: Colors.orange.shade800,
                        titolo: AppTesti.get('btn_le_mie_piante', linguaAttuale),
                        sottotitolo: isIt ? 'Gestisci la tua serra' : 'Manage your greenhouse',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPlantsScreen())),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async => await authCtrl.esci(),
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          label: Text(isIt ? 'Esci dall\'account' : 'Log out', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}