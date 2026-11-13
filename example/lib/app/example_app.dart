import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import 'example_shell.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _dark = Uri.base.queryParameters['dark'] == '1';

  void _toggleTheme() => setState(() => _dark = !_dark);

  @override
  Widget build(BuildContext context) {
    return FFBreakpointScope(
      breakpoints: const FFBreakpoints(sm: 640, md: 900, lg: 1200, xl: 1600),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        home: ExampleShell(isDarkMode: _dark, onToggleTheme: _toggleTheme),
      ),
    );
  }
}
