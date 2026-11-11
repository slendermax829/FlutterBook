import 'package:flutter/material.dart';
import 'package:flutter_book/menu.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteModel()),
        ChangeNotifierProvider(create: (_) => TaskModel()),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
          backgroundColor: Colors.grey.withValues(alpha: .35),
          
        )
      ),
      home: const Menu()
    );
  }
}