import 'dart:math';
import 'package:flutter/material.dart';

class MemoramaGame extends StatefulWidget {
  const MemoramaGame({super.key});

  @override
  State<MemoramaGame> createState() => _MemoramaGameState();
}

class _MemoramaGameState extends State<MemoramaGame> {
  int rows = 5;
  int cols = 4;
  List<List<Color>> gameColors = [];
  List<List<bool>> revealed = [];
  List<List<bool>> matched = [];

  Color firstSelectedColor = Colors.transparent;
  int firstSelectedRow = -1;
  int firstSelectedCol = -1;
  bool canTap = true;
  bool gameCompleted = false;

  final Color inactiveColor = Colors.grey[400]!;
  final Random random = Random();


  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    gameColors = List.generate(rows, (i) => List.generate(cols, (j) => inactiveColor));
    revealed = List.generate(rows, (i) => List.generate(cols, (j) => false));
    matched = List.generate(rows, (i) => List.generate(cols, (j) => false));

    List<Color> gameColorList = [];
    for (int i = 0; i < 10; i++) {
      gameColorList.add(availableColors[i]);
      gameColorList.add(availableColors[i]);
    }

    for (int i = 0; i < 100; i++) {
      int pos1 = random.nextInt(20);
      int pos2 = random.nextInt(20);
      Color temp = gameColorList[pos1];
      gameColorList[pos1] = gameColorList[pos2];
      gameColorList[pos2] = temp;
    }

    int index = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        gameColors[i][j] = gameColorList[index];
        index++;
      }
    }

    firstSelectedColor = Colors.transparent;
    firstSelectedRow = -1;
    firstSelectedCol = -1;
    canTap = true;
    gameCompleted = false;
  }

  void onCardTap(int row, int col) {
    if (!canTap || revealed[row][col] || matched[row][col]) return;

    setState(() {
      revealed[row][col] = true;
    });

    if (firstSelectedColor == Colors.transparent) {
      firstSelectedColor = gameColors[row][col];
      firstSelectedRow = row;
      firstSelectedCol = col;
    } else {
      canTap = false;

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          if (gameColors[row][col] == firstSelectedColor) {
            matched[firstSelectedRow][firstSelectedCol] = true;
            matched[row][col] = true;

            if (checkGameCompleted()) {
              gameCompleted = true;
            }
          } else {
            revealed[firstSelectedRow][firstSelectedCol] = false;
            revealed[row][col] = false;
          }

          firstSelectedColor = Colors.transparent;
          firstSelectedRow = -1;
          firstSelectedCol = -1;
          canTap = true;
        });
      });
    }
  }

  bool checkGameCompleted() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!matched[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    setState(() {
      initializeGame();
    });
  }


  Color getCardColor(int row, int col) {
    if (matched[row][col] == true) {
      return gameColors[row][col];
    }
    if (revealed[row][col] == true) {
      return gameColors[row][col];
    }
    return inactiveColor;
  }

  @override
  Widget build(BuildContext context) {
    if (gameCompleted) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Memorama'),
          centerTitle: true,
          backgroundColor: Colors.blue[100],
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Juego Terminado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Felicidades! Has completado el memorama',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Jugar de nuevo'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Memorama'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Andrés Aguirre Otero',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  int row = index ~/ cols;
                  int col = index % cols;

                  return GestureDetector(
                    onTap: () => onCardTap(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        color: getCardColor(row, col),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: resetGame,
              child: const Text('Reiniciar'),
            ),
          ),
        ],
      ),
    );
  }
}