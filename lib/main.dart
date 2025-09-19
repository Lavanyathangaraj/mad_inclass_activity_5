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
      theme: ThemeData(primarySwatch: Colors.teal),
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
  int energyLevel = 100;
  final TextEditingController _nameController = TextEditingController();
  bool nameSet = false;
  bool gameEnded = false;

  Timer? hungerTimer;
  DateTime? happinessAbove80Start;

  final List<String> activities = ['Play', 'Feed', 'Train', 'Run', 'Sleep'];
  String selectedActivity = 'Play';

  @override
  void initState() {
    super.initState();
    startHungerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkWinLoss());
  }

  void startHungerTimer() {
    hungerTimer?.cancel();
    hungerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (gameEnded) return;
      setState(() {
        hungerLevel += 5;
        energyLevel -= 5;
        if (hungerLevel > 100) {
          hungerLevel = 100;
          happinessLevel -= 20;
          if (happinessLevel < 0) happinessLevel = 0;
        }
        if (energyLevel < 0) energyLevel = 0;
        checkWinLoss();
      });
    });
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    super.dispose();
  }

  Color getPetOverlayColor() {
    if (happinessLevel > 70) return Colors.green.withOpacity(0.5);
    if (happinessLevel >= 30) return Colors.yellow.withOpacity(0.5);
    return Colors.red.withOpacity(0.5);
  }

  Color getEnergyBarColor() {
    if (energyLevel > 80) return Colors.greenAccent;
    if (energyLevel > 50) return Colors.lightBlueAccent;
    if (energyLevel > 30) return Colors.yellowAccent;
    return Colors.redAccent;
  }

  String getPetMood() {
    if (happinessLevel > 70) return "Happy 🤩";
    if (happinessLevel >= 30) return "Neutral 🙂";
    return "Unhappy 😣";
  }

  void performActivity(String activity) {
    if (gameEnded) return;
    setState(() {
      switch (activity) {
        case 'Play':
          happinessLevel += 10;
          energyLevel -= 10;
          updateHunger();
          break;
        case 'Feed':
          hungerLevel -= 10;
          energyLevel += 5;
          updateHappiness();
          break;
        case 'Train':
          happinessLevel -= 5;
          energyLevel -= 15;
          updateHunger();
          break;
        case 'Run':
          happinessLevel += 5;
          energyLevel -= 20;
          updateHunger();
          break;
        case 'Sleep':
          energyLevel += 30;
          if (energyLevel > 100) energyLevel = 100;
          hungerLevel += 10;
          if (hungerLevel > 100) hungerLevel = 100;
          break;
      }

      if (happinessLevel > 100) happinessLevel = 100;
      if (happinessLevel < 0) happinessLevel = 0;
      if (energyLevel < 0) energyLevel = 0;
      if (hungerLevel < 0) hungerLevel = 0;
      if (hungerLevel > 100) hungerLevel = 100;

      checkWinLoss();
    });
  }

  void updateHappiness() {
    if (gameEnded) return;
    if (hungerLevel < 30) {
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    } else {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
    }
  }

  void updateHunger() {
    if (gameEnded) return;
    hungerLevel += 5;
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel -= 20;
      if (happinessLevel < 0) happinessLevel = 0;
    }
  }

  void setPetName() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        petName = _nameController.text;
        nameSet = true;
      });
    }
  }

  void checkWinLoss() {
    if (gameEnded) return;

    if (hungerLevel == 100 && happinessLevel <= 10) {
      gameEnded = true;
      hungerTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEndDialog("Game Over!!!");
      });
      return;
    }

    if (happinessLevel > 80) {
      if (happinessAbove80Start == null) {
        happinessAbove80Start = DateTime.now();
      } else {
        final elapsed = DateTime.now().difference(happinessAbove80Start!).inSeconds;
        if (elapsed >= 90) {
          gameEnded = true;
          hungerTimer?.cancel();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showEndDialog("You Won!!!");
          });
        }
      }
    } else {
      happinessAbove80Start = null;
    }
  }

  void showEndDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text("Restart Game"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      petName = "";
      nameSet = false;
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 100;
      selectedActivity = 'Play';
      gameEnded = false;
      happinessAbove80Start = null;
      hungerTimer?.cancel();
      startHungerTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: nameSet ? buildPetScreen() : buildNameInputScreen(),
    );
  }

  Widget buildNameInputScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Enter your pet's name:", style: TextStyle(fontSize: 20.0)),
          const SizedBox(height: 16.0),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Pet Name",
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(onPressed: setPetName, child: const Text("Submit")),
        ]),
      ),
    );
  }

  Widget buildPetScreen() {
    return Container(
      color: const Color(0xFFE0F7FA),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Name: $petName', style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 8.0),
          Text('Mood: ${getPetMood()}', style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 16.0),
          Image.asset(
            'assets/images/dog.jpeg',
            height: 250,
            width: 450,
            color: getPetOverlayColor(),
            colorBlendMode: BlendMode.modulate,
          ),
          const SizedBox(height: 16.0),
          Text('Happiness Level: $happinessLevel', style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 16.0),
          Text('Hunger Level: $hungerLevel', style: const TextStyle(fontSize: 20.0)),
          const SizedBox(height: 16.0),
          Text('Energy Level: $energyLevel', style: const TextStyle(fontSize: 20.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(
              value: energyLevel / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: getEnergyBarColor(),
            ),
          ),
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: DropdownButton<String>(
              value: selectedActivity,
              isExpanded: true,
              onChanged: (String? value) {
                if (value != null) selectedActivity = value;
                setState(() {});
              },
              items: activities.map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => performActivity(selectedActivity),
            child: const Text('Perform Activity'),
          ),
        ]),
      ),
    );
  }
}
