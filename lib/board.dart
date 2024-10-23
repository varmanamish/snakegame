import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snakegame/tile.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

//possible sanke directions
enum DIRECTION {
  left,
  right,
  up,
  down,
}

class _SnakeGameState extends State<SnakeGame> {
  //board dimensions
  int rowCount = 10;
  int colCount = 10;

  //snake postition
  List<int> snakePos = [0, 1, 2, 3];
  var snakeDirection = DIRECTION.right;

  //food position
  int foodPos = 14;

  //game variables
  bool isPlaying = false;
  int score = 0;
  int gameSpeed = 300; //ms

  //timer and random number generator
  late Timer gameLoopTimer;
  Random random = Random();

  //start game!
  void startGame() {
    if (isPlaying) return;

    setState(() {
      isPlaying = true;
      score = 0;
      snakePos = [0, 1, 2, 3];
      snakeDirection = DIRECTION.right;
      foodPos = random.nextInt(rowCount * colCount);
    });

    gameLoopTimer =
        Timer.periodic(Duration(milliseconds: gameSpeed), (Timer timer) {
      setState(() {
        moveSnake();
        if (checkGameOver()) {
          timer.cancel();
          isPlaying = false;
          _showGameOverDialog();
        }
      });
    });
  }

  void moveSnake() {
    int nextPos;

    switch (snakeDirection) {
      case DIRECTION.right:
        nextPos = (snakePos.last + 1) % (rowCount * colCount);
        if (nextPos % colCount == 0) {
          nextPos -= colCount;
        }
        break;
      case DIRECTION.left:
        nextPos =
            (snakePos.last - 1 + rowCount * colCount) % (rowCount * colCount);
        if (nextPos % colCount == colCount - 1) {
          nextPos += colCount;
        }
        break;
      case DIRECTION.up:
        nextPos = (snakePos.last - colCount + rowCount * colCount) %
            (rowCount * colCount);
        break;
      case DIRECTION.down:
        nextPos = (snakePos.last + colCount) % (rowCount * colCount);
        break;
    }

    if (nextPos == foodPos) {
      snakePos.add(nextPos);
      foodPos = generateNewFoodPos();
      score++;
    } else {
      snakePos.add(nextPos);
      snakePos.removeAt(0);
    }
  }

  //Generate a new position for the food
  int generateNewFoodPos() {
    int newPos;
    do {
      newPos = random.nextInt(rowCount * colCount);
    } while (snakePos.contains(newPos));
    return newPos;
  }

  //Check if the game is over (collision with self)
  bool checkGameOver() {
    List<int> body = snakePos.sublist(0, snakePos.length - 1);
    if (body.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  //Show a dialog when the game is over
  void _showGameOverDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text('Your Score: $score'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: Text('Play Again'))
            ],
          );
        });
  }

  //Handle the snake direction change
  void changeDirection(DIRECTION direction) {
    if ((direction == DIRECTION.left && snakeDirection != DIRECTION.right) ||
        (direction == DIRECTION.right && snakeDirection != DIRECTION.left) ||
        (direction == DIRECTION.up && snakeDirection != DIRECTION.down) ||
        (direction == DIRECTION.down && snakeDirection != DIRECTION.up)) {
      setState(() {
        snakeDirection = direction;
      });
    }
  }

  @override
  void dispose() {
    gameLoopTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          print("Swiping Down");
          changeDirection(DIRECTION.down);
        } else if (details.delta.dy < 0) {
          print("Swiping Up");
          changeDirection(DIRECTION.up);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          print("Swiping Right");
          changeDirection(DIRECTION.right);
        } else if (details.delta.dx < 0) {
          print("Swiping Left");
          changeDirection(DIRECTION.left);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: rowCount * colCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colCount),
                itemBuilder: (context, index) {
                  //snake tile
                  if (snakePos.contains(index)) {
                    return Tile(
                      lightOn: true,
                    );
                  }
                  //food tile
                  else if (index == foodPos) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      color: Colors.blue,
                    );
                  }
                  //blank tile
                  else {
                    return Tile(lightOn: false);
                  }
                },
              ),
            ),

            //restart button
            MaterialButton(
              onPressed: startGame,
              color: Colors.green,
              child: const Text('Play'),
            )
          ],
        ),
      ),
    );
  }
}
