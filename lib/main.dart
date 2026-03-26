import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

// Services
import 'data/services/firebase_service.dart';
import 'data/services/callkit_service.dart';
import 'data/services/storage_service.dart';
import 'core/network/backend_selector.dart';

// Providers
import 'providers/call_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/call/call_screen.dart';
import 'presentation/screens/call/video_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  try {
    await BackendSelector.init();
    await dotenv.load(fileName: ".env");
    await StorageService.init();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService.initialize();

    // Notification channel
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificações Importantes',
      description: 'Canal para alertas urgentes da EVA.',
      importance: Importance.max,
    );
    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(highChannel);
    }
    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: initAndroid);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await androidImpl?.requestNotificationsPermission();

    // CallProvider
    final callProvider = await CallProvider.create();

    FirebaseService.onVoiceCallReceived = (sessionId, idosoData) {
      callProvider.receiveCall(sessionId, idosoData: idosoData);
    };

    FirebaseService.startListening();
    CallKitService.listenEvents();

    runApp(MyApp(callProvider: callProvider));
  } catch (e, stackTrace) {
    logger.e('Error during initialization: $e\n$stackTrace');
    final fallbackProvider = CallProvider.fallback();
    runApp(MyApp(callProvider: fallbackProvider));
  }
}

class MyApp extends StatefulWidget {
  final CallProvider callProvider;
  const MyApp({super.key, required this.callProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final initialRoute = StorageService.isLoggedIn() ? '/home' : '/login';
    _router = _createRouter(initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: widget.callProvider),
      ],
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (!didPop) SystemNavigator.pop();
        },
        child: MaterialApp.router(
          title: 'EVA Mobile',
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF9F70D8),
            useMaterial3: true,
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
        ),
      ),
    );
  }

  GoRouter _createRouter(String initialRoute) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/call',
          name: 'call',
          builder: (context, state) => const CallScreen(),
        ),
        GoRoute(
          path: '/video',
          name: 'video',
          builder: (context, state) => const VideoScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text('Rota não encontrada: ${state.matchedLocation}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
