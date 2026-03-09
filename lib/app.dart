// =============================================================================
// PHỎNG VẤN KIẾN THỨC - app.dart (Root widget)
// =============================================================================
//
//   Q1. StatelessWidget khác StatefulWidget thế nào? MyApp dùng Stateless vì sao?
//   A1. StatelessWidget: không giữ state, build() chỉ phụ thuộc config (props). StatefulWidget:
//       có State, setState() đổi state → rebuild. MyApp không cần state nội bộ, cấu hình
//       cố định (providers, theme, home) → Stateless là đủ.
//
//   Q2. MultiBlocProvider dùng để làm gì? BlocProvider(create: (_) => FormCubit()) nghĩa là gì?
//   A2. MultiBlocProvider gộp nhiều BlocProvider, "tiêm" nhiều Bloc vào cây một lúc. BlocProvider
//       (create: (_) => FormCubit()) nghĩa là: khi widget này được build lần đầu, tạo 1 instance
//       FormCubit và cung cấp cho mọi descendant qua InheritedWidget (context.read/of).
//
//   Q3. FormCubit và LoginBloc được tạo ở đâu? AuthScreen lấy chúng bằng cách nào?
//   A3. Tạo trong BlocProvider(create: ...) khi build MultiBlocProvider. AuthScreen (và mọi
//       widget con) lấy bằng context.read<FormCubit>(), context.read<LoginBloc>() hoặc
//       BlocProvider.of<FormCubit>(context); BlocBuilder/BlocConsumer cũng tìm Bloc trong ancestor.
//
//   Q4. MaterialApp có vai trò gì? home và routes khác nhau thế nào?
//   A4. MaterialApp: cấu hình Material design (theme, navigator, locale...). home là màn hình
//       mặc định (widget hiển thị đầu tiên). routes là map tên route → builder; dự án này
//       không dùng routes named, sau login dùng pushReplacement(MaterialPageRoute(...)).
//
//   Q5. ThemeData (colorScheme, textTheme, appBarTheme...) áp dụng cho đâu? Widget con kế thừa thế nào?
//   A5. ThemeData áp dụng cho toàn bộ cây dưới MaterialApp. Widget con lấy bằng
//       Theme.of(context) (hoặc Theme.of(context).colorScheme, textTheme...). InheritedWidget
//       nên thay đổi theme ở MaterialApp sẽ ảnh hưởng toàn app.
//
// =============================================================================
// LOGIC TRONG FILE:
//   MyApp (StatelessWidget) → build() return 1 cây: MultiBlocProvider [cha]
//     → child: MaterialApp [con].
//   MultiBlocProvider: tạo và "đẩy" FormCubit + LoginBloc vào InheritedContext.
//   Mọi widget con (AuthScreen, rồi HomeScreen...) đều có thể BlocProvider.of
//   hay context.read<FormCubit>() / context.read<LoginBloc>() để dùng.
//   MaterialApp: quy định theme (màu, font, card, input) và home = AuthScreen.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN:
//   AuthScreen cần FormCubit (form email/password) và LoginBloc (đăng nhập/đăng ký).
//   Hai Bloc này phải có sẵn ở đỉnh cây (tại đây) thì BlocBuilder/BlocConsumer
//   trong AuthScreen mới tìm thấy. Sau LoginSuccess, AuthScreen tự
//   pushReplacement(HomeScreen) — không dùng routes named.
// -----------------------------------------------------------------------------

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
        BlocProvider(create: (_) => LoginBloc(AuthRepository())),
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
