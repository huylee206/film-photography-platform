import 'package:flutter/material.dart';

void main() {
  runApp(const FpdpMobileApp());
}

class FpdpMobileApp extends StatelessWidget {
  const FpdpMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPDP Photographer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FPDP – Darkroom & Studio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.camera_roll, color: Colors.amber),
              title: Text('Phòng Tối B&W Đỏ Ilford #01'),
              subtitle: Text('180.000 đ/giờ • Safelight SL1 • Quạt hút 350 m3/h'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.qr_code_scanner, color: Colors.amber),
              title: Text('Quét QR Check-in Phiên Sử Dụng'),
              subtitle: Text('Bắt đầu ServiceSession tại phòng tối / studio'),
            ),
          ),
        ],
      ),
    );
  }
}
