import 'package:flutter/material.dart';

void main() {
  runApp(const FilmPlatformApp());
}

class FilmPlatformApp extends StatelessWidget {
  const FilmPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Photography Platform',
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Film Photography Platform\nConnected to SOA API Gateway (:4000)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
