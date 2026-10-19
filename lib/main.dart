import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme_config.dart';
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

/// Racine de l'app : démarre directement sur l'écran d'accueil Onboarding
/// avec l'aile d'avion et le logo en papier (Capture 1).
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    kReplaySignal.addListener(_handleReplay);
  }

  @override
  void dispose() {
    kReplaySignal.removeListener(_handleReplay);
    super.dispose();
  }

  void _handleReplay() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(
      key: ValueKey(kReplaySignal.value),
      config: ThemeConfig.current,
    );
  }
}
