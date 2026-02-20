import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/auth/auth_screen.dart';
import 'presentation/auth/form/form_cubit.dart';
import 'presentation/auth/login/login_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FormCubit()),
        BlocProvider(
          create: (_) => LoginBloc(AuthRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Shopping Cart Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
            primaryContainer: const Color(0xFFE0E7FF),
            surface: const Color(0xFFF8FAFC),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AuthScreen(),
      ),
    );
  }
}
