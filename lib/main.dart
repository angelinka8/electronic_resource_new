import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Электронный ресурс',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isConnected = true;
  bool _isLoading = false;
  bool _isBiometricEnabled = true;

  void _openDoor() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет соединения с сервером. Офлайн-режим.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дверь открыта!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildAccessScreen(),
      _buildHistoryScreen(),
      _buildGuestPassScreen(),
      _buildSettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронный ресурс'),
        centerTitle: true,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.door_front_door), label: 'Доступ'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Гостевой пропуск'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }

  Widget _buildAccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _openDoor,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open, size: 60, color: Colors.white),
                          SizedBox(height: 10),
                          Text('Открыть', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ),const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 16, color: _isConnected ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(_isConnected ? 'Подключено' : 'Офлайн', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(leading: Icon(Icons.login, color: Colors.green), title: Text('Вход в здание'), subtitle: Text('Сегодня, 08:30 • Главный вход')),
        ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Выход из здания'), subtitle: Text('Сегодня, 18:00 • Главный вход')),
        ListTile(leading: Icon(Icons.meeting_room, color: Colors.blue), title: Text('Открытие двери (мобильно)'), subtitle: Text('Вчера, 14:15 • Офис 302')),
      ],
    );
  }

  Widget _buildGuestPassScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]),
            child: const Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Text('Одноразовый пропуск', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Действителен до 18:00'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пропуск отправлен!')));
            },
            icon: const Icon(Icons.share),
            label: const Text('Отправить гостю'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Профиль пользователя'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Биометрия'),
          trailing: Switch(
            value: _isBiometricEnabled,
            onChanged: (bool value) {
              setState(() {
                _isBiometricEnabled = value;
              });
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сканирование отпечатка пальца... Успешно!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Безопасность'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Раздел безопасности в разработке')));
          },
        ),
      ],
    );
  }
}class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 60, color: Colors.white)),
            SizedBox(height: 20),
            Text('Ангелина', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Студент / Сотрудник', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 10),
            Text('ID: 100245', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}