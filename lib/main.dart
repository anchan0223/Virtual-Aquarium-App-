import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:async';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  Color selectedColor = Colors.blue;
  double selectedSpeed = 1.0;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aquarium')),
      body: Column(
        children: [
          Container(
            height: 300,
            width: 300,
            color: Colors.blue[100],
            child: Stack(
              children:
                  fishList.map((fish) => AnimatedFish(fish: fish)).toList(),
            ),
          ),
          Slider(
            value: selectedSpeed,
            min: 0.5,
            max: 5.0,
            onChanged: (newValue) {
              setState(() {
                selectedSpeed = newValue;
              });
            },
            label: 'Speed: $selectedSpeed',
          ),
          DropdownButton<Color>(
            value: selectedColor,
            items: [
              DropdownMenuItem(child: Text("Blue"), value: Colors.blue),
              DropdownMenuItem(child: Text("Red"), value: Colors.red),
              DropdownMenuItem(child: Text("Green"), value: Colors.green),
            ],
            onChanged: (newValue) {
              setState(() {
                selectedColor = newValue!;
              });
            },
          ),
          ElevatedButton(
            onPressed: _addFish,
            child: Text("Add Fish"),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text("Save Settings"),
          ),
        ],
      ),
    );
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  Future<void> _saveSettings() async {
    await dbHelper.insert({
      DatabaseHelper.columnFishCount: fishList.length,
      DatabaseHelper.columnSpeed: selectedSpeed,
      DatabaseHelper.columnColor: selectedColor.toString(),
    });
    print("Settings saved!");
  }

  Future<void> _loadSettings() async {
    var settings = await dbHelper.queryAllRows();
    if (settings.isNotEmpty) {
      var savedSettings = settings.first;
      setState(() {
        selectedSpeed = savedSettings[DatabaseHelper.columnSpeed];
        selectedColor = _parseColor(savedSettings[DatabaseHelper.columnColor]);
        for (int i = 0;
            i < savedSettings[DatabaseHelper.columnFishCount];
            i++) {
          fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
        }
      });
    }
  }

  Color _parseColor(String colorString) {
    if (colorString.contains("blue")) {
      return Colors.blue;
    } else if (colorString.contains("red")) {
      return Colors.red;
    } else if (colorString.contains("green")) {
      return Colors.green;
    } else {
      return Colors.blue; // default
    }
  }
}

class Fish {
  Color color;
  double speed;

  Fish({required this.color, required this.speed});
}

class AnimatedFish extends StatefulWidget {
  final Fish fish;

  AnimatedFish({required this.fish});

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _position;
  Offset _velocity;

  _AnimatedFishState()
      : _position = Offset(0, 0),
        _velocity = Offset(1, 1); // Initial velocity

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 16), // Control update frequency
      vsync: this,
    )
      ..addListener(_updatePosition)
      ..repeat();
  }

  void _updatePosition() {
    setState(() {
      // Update position
      _position += _velocity * widget.fish.speed;

      // Check for boundaries and bounce back if necessary
      if (_position.dx >= 280 || _position.dx <= 0) {
        _velocity = Offset(-_velocity.dx, _velocity.dy); // Bounce horizontally
      }
      if (_position.dy >= 280 || _position.dy <= 0) {
        _velocity = Offset(_velocity.dx, -_velocity.dy); // Bounce vertically
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.fish.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
