import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/decision_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TiebreakerApp());
}

class TiebreakerApp extends StatelessWidget {
  const TiebreakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DecisionProvider(),
      child: MaterialApp(
        title: 'Tiebreaker AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}