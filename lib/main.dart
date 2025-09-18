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

  Color getPetOverlayColor() {
    if (happinessLevel > 70) {
      return Colors.green.withOpacity(0.5);
    } else if (happinessLevel >= 30) {
      return Colors.yellow.withOpacity(0.5);
    } else {
      return Colors.red.withOpacity(0.5);
    }
  }

  String getPetMood() {
    if (happinessLevel > 70) return "Happy 🤩";
    if (happinessLevel >= 30) return "Neutral 🙂";
    return "Unhappy 😣";
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
      _updateHunger();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      _updateHappiness();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    } else {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
    }
  }

  void _updateHunger() {
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
              height: 350,
              width: 500,
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
