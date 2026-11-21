import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';
import 'package:flutter_book/calculator/calculator_model.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:flutter_book/menu.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

/// Initializes the app with its section model providers.
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  debugPrint('User: ${FirebaseAuth.instance.currentUser?.uid}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteModel()),
        ChangeNotifierProvider(create: (_) => CalendarModel()),
        ChangeNotifierProvider(create: (_) => CalculatorModel()),
        ChangeNotifierProvider(create: (_) => BookmarkModel())
      ],
      child: MyApp(),
    )
  );
}

/// Configures the app's theme and root menu.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        tabBarTheme: TabBarThemeData(
          labelColor: Colors.blue,
          overlayColor: WidgetStateProperty.all(Colors.grey.withValues(alpha: 0.2))
        ),
        colorScheme: const ColorScheme.dark(
            surface: Colors.black,
            surfaceContainer: Colors.black12,
            error: Colors.redAccent,
          ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey.withValues(alpha: .2)
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white)
          )
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.withValues(alpha: .2),
            side: BorderSide(color: Colors.white)
          )
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey,
        ),
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(color: Colors.white),
          backgroundColor: Colors.grey,
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStatePropertyAll(Colors.white)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            iconColor: Colors.white,
            foregroundColor: Colors.white,
          )
        ),
        datePickerTheme: DatePickerThemeData(
          
        )
      ),
      home: const Menu()
    );
  }
}