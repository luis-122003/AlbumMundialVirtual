import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/coleccion_controller.dart';
import 'controllers/lamina_controller.dart';
import 'controllers/intercambio_controller.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/home/home_view.dart';
import 'views/coleccion/coleccion_view.dart';
import 'views/scanner/scanner_view.dart';
import 'views/perfil/perfil_view.dart';
import 'views/intercambios/intercambios_view.dart';

const kNavy = Color(0xFF0D1B2A);
const kNavyMid = Color(0xFF1E3A5F);
const kGold = Color(0xFFC9A227);
const kGoldLight = Color(0xFFFFD700);
const kSurface = Color(0xFFF4F6F9);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ColeccionController()),
        ChangeNotifierProvider(create: (_) => LaminaController()),
        ChangeNotifierProvider(create: (_) => IntercambioController()),
      ],
      child: const PaniniApp(),
    ),
  );
}

class PaniniApp extends StatelessWidget {
  const PaniniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panini Mundial 2026',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _AppRoot(),
    );
  }

  static ThemeData _buildTheme() {
    final cs = ColorScheme.fromSeed(
      seedColor: kNavy,
      brightness: Brightness.light,
    ).copyWith(
      primary: kNavy,
      onPrimary: Colors.white,
      primaryContainer: kNavyMid,
      onPrimaryContainer: Colors.white,
      secondary: kGold,
      onSecondary: kNavy,
      secondaryContainer: const Color(0xFFFFF8E1),
      onSecondaryContainer: const Color(0xFF4D3800),
      surface: Colors.white,
      onSurface: kNavy,
      surfaceContainerLowest: kSurface,
      surfaceContainerHighest: const Color(0xFFE2EAF4),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE8EDF5),
    );

    return ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: kSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: kGold,
        unselectedLabelColor: Color(0xFF8BA3C0),
        indicatorColor: kGold,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        dividerColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kNavy,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black45,
        elevation: 8,
        indicatorColor: kGold,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: kNavy, size: 22);
          }
          return const IconThemeData(color: Color(0xFF607D9B), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: kGold,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return const TextStyle(color: Color(0xFF607D9B), fontSize: 11);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kNavyMid, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF607D8B), fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF90A4AE)),
        prefixIconColor: kNavyMid,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        backgroundColor: const Color(0xFFE8EDF5),
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: kNavy,
        ),
        padding: EdgeInsets.zero,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: kGold,
        linearTrackColor: Color(0xFFE2EAF4),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EDF5),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ─── App Root ────────────────────────────────────────────────────────────────

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthController>().tryAutoLogin();
    if (mounted) setState(() => _initializing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: kNavy,
        body: Center(
          child: CircularProgressIndicator(color: kGold),
        ),
      );
    }

    final isAuth = context.watch<AuthController>().isAuthenticated;
    return isAuth ? const _MainShell() : const _AuthFlow();
  }
}

// ─── Auth Flow ───────────────────────────────────────────────────────────────

class _AuthFlow extends StatefulWidget {
  const _AuthFlow();

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginView(
        onGoToRegister: () => setState(() => _showLogin = false),
      );
    }
    return RegisterView(
      onGoToLogin: () => setState(() => _showLogin = true),
    );
  }
}

// ─── Main Shell ──────────────────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeView(),
    ColeccionView(),
    ScannerView(),
    IntercambiosView(),
    PerfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Álbum',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Escáner',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Intercambios',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
