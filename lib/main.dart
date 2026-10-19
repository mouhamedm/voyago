import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme_config.dart';
import 'features/intro/preloader_screen.dart';
import 'features/intro/welcome_screen.dart';

/// Incrémenté pour réinitialiser ou rejouer le flow depuis l'extérieur.
final ValueNotifier<int> kReplaySignal = ValueNotifier<int>(0);

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar transparente, pas de barre de debug visuelle superflue.
  final config = ThemeConfig.current;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: config.isLight ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: config.isLight ? Brightness.dark : Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    DevicePreview(
      enabled:
          !kReleaseMode &&
          (kIsWeb ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows),
      isToolbarVisible: false,
      backgroundColor: Colors.grey[900],
      defaultDevice: Devices.ios.iPhone15Pro,
      builder: (context) => const VoyagoApp(),
    ),
  );
}

class VoyagoApp extends StatelessWidget {
  const VoyagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ThemeConfig.current;
    return MaterialApp(
      locale: DevicePreview.locale(context),
      navigatorKey: _navigatorKey,
      title: config.brandName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: config.isLight ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: config.backgroundBottom,
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.accent,
          brightness: config.isLight ? Brightness.light : Brightness.dark,
        ),
      ),
      builder: (context, child) {
        return DevicePreview.appBuilder(
          context,
          child ?? const SizedBox.shrink(),
        );
      },
      home: const AppRoot(),
    );
  }
}

/// Racine de l'app : démarre systématiquement par le flow d'introduction
/// (preloader puis welcome/login).
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: kReplaySignal,
      builder: (context, replayCount, _) {
        return IntroFlowHost(key: ValueKey(replayCount));
      },
    );
  }
}

/// Orchestration continue preloader -> welcome : le même fond dégradé
/// persiste pendant tout le flow, aucune coupure sèche entre les séquences.
class IntroFlowHost extends StatefulWidget {
  const IntroFlowHost({super.key});

  @override
  State<IntroFlowHost> createState() => _IntroFlowHostState();
}

class _IntroFlowHostState extends State<IntroFlowHost> {
  bool _showWelcome = false;

  @override
  Widget build(BuildContext context) {
    final config = ThemeConfig.current;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: config.backgroundGradient),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: [...previousChildren, ?currentChild],
          ),
          child: _showWelcome
              ? WelcomeScreen(key: const ValueKey('welcome'), config: config)
              : PreloaderScreen(
                  key: const ValueKey('preloader'),
                  config: config,
                  onComplete: () => setState(() => _showWelcome = true),
                ),
        ),
      ),
    );
  }
}
