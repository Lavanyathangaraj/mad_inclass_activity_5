import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Digital Pet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String petName = "";
  int happinessLevel = 50;
  int hungerLevel = 50;
  final TextEditingController _nameController = TextEditingController();
  bool _nameSet = false;

  Timer? _hungerTimer;
  Timer? _winTimer;
  bool _winTimerStarted = false;
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_gameEnded) return;
      setState(() {
        hungerLevel += 5;
        if (hungerLevel > 100) {
          hungerLevel = 100;
          happinessLevel -= 20;
          if (happinessLevel < 0) happinessLevel = 0;
        }
        _checkWinLoss();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWinLoss();
    });
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    super.dispose();
  }

  Color getPetOverlayColor() {
    if (happinessLevel > 70) return Colors.green.withOpacity(0.5);
    if (happinessLevel >= 30) return Colors.yellow.withOpacity(0.5);
    return Colors.red.withOpacity(0.5);
  }

  String getPetMood() {
    if (happinessLevel > 70) return "Happy 🤩";
    if (happinessLevel >= 30) return "Neutral 🙂";
    return "Unhappy 😣";
  }

  void _playWithPet() {
    if (_gameEnded) return;
    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
      _updateHunger();
      _checkWinLoss();
    });
  }

  void _feedPet() {
    if (_gameEnded) return;
    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      _updateHappiness();
      _checkWinLoss();
    });
  }

  void _updateHappiness() {
    if (_gameEnded) return;
    if (hungerLevel < 30) {
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    } else {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
    }
  }

  void _updateHunger() {
    if (_gameEnded) return;
    hungerLevel += 5;
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    }
  }

  void _setPetName() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        petName = _nameController.text;
        _nameSet = true;
      });
    }
  }

  void _checkWinLoss() {
    if (_gameEnded) return;

    if (hungerLevel == 100 && happinessLevel <= 10) {
      _gameEnded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEndDialog("Game Over!!");
      });
      _hungerTimer?.cancel();
      _winTimer?.cancel();
      return;
    }

    if (happinessLevel > 80) {
      if (!_winTimerStarted) {
        _winTimerStarted = true;
        _winTimer = Timer(const Duration(minutes: 3), () {
          if (!_gameEnded && happinessLevel > 80) {
            _gameEnded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEndDialog("You Won!!");
            });
            _hungerTimer?.cancel();
          }
        });
      }
    } else {
      _winTimerStarted = false;
      _winTimer?.cancel();
    }
  }

  void _showEndDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _nameSet ? _buildPetScreen() : _buildNameInputScreen(),
    );
  }

  Widget _buildNameInputScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your pet's name:",
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Pet Name",
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _setPetName,
              child: const Text("Confirm Name"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/dog.jpeg',
              height: 250,
              width: 450,
              color: getPetOverlayColor(),
              colorBlendMode: BlendMode.modulate,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Name: $petName',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Mood: ${getPetMood()}',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: const Text('Play with Your Pet'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: const Text('Feed Your Pet'),
            ),
          ],
        ),
      ),
    );
  }
}
