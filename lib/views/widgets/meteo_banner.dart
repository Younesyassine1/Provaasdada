// ============================================================
// FILE: meteo_banner.dart
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/app_strings.dart';

class MeteoBanner extends ConsumerStatefulWidget {
  final Lingua linguaAttuale;

  const MeteoBanner({Key? key, required this.linguaAttuale}) : super(key: key);

  @override
  ConsumerState<MeteoBanner> createState() => _MeteoBannerState();
}

class _MeteoBannerState extends ConsumerState<MeteoBanner> {
  bool _visibile = true;
  Timer? _timerScomparsa;

  @override
  void initState() {
    super.initState();
    final meteoCtrl = ref.read(meteoProvider);
    meteoCtrl.pioveOggi.addListener(_gestisciTimer);
    meteoCtrl.verificaMeteo();
  }

  void _gestisciTimer() {
    final meteoCtrl = ref.read(meteoProvider);
    if (meteoCtrl.pioveOggi.value == true) {
      _timerScomparsa = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _visibile = false);
      });
    }
  }

  @override
  void dispose() {
    ref.read(meteoProvider).pioveOggi.removeListener(_gestisciTimer);
    _timerScomparsa?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meteoCtrl = ref.watch(meteoProvider);

    return ValueListenableBuilder<bool?>(
      valueListenable: meteoCtrl.pioveOggi,
      builder: (context, piove, child) {
        if (piove == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)),
              ),
            ),
          );
        }

        if (piove == false) return const SizedBox.shrink();

        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: _visibile
              ? Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: Color(0xFF4CAF50), width: 4)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌧️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      AppTesti.get('meteo_allerta_titolo', widget.linguaAttuale),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  AppTesti.get('meteo_allerta_testo', widget.linguaAttuale),
                  style: const TextStyle(color: Color(0xFF388E3C), fontSize: 13),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}