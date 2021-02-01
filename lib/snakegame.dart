import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int sqrPerRow = 20;
  final int sqpPerCol = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;

  void startGame() {
    //move 1 step every 200ms
    const duration = Duration(milliseconds: 200);

    ///Set the snake at the center
    snake = [
      //snake head
      [(sqrPerRow / 2).floor(), (sqpPerCol / 2).floor()]
    ];
    snake.add([snake.first[0], snake.first[1] - 1]); //snake body

    // call createFood() function to create food
    createFood();

    isPlaying = true;

    //Use Timer.periodic time to animate certain object widgets
    Timer.periodic(duration, (Timer timer) {
      // call the moveSnake() function to move the snake.
      moveSnake();

      //Check if is game over by calling checkGameOver() function
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {

        /// Center position will be like this
        /// snake.insert(0,  [snake.first[0], snake.first[0]])
        /// x = 0 & y= 0
        case 'up':
          // Deduct 1 to the y-position
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case 'down':
          // Add 1 to the y-position
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;
        case 'left':
          // Deduct 1 to the x-position
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
        case 'right':
          // Add 1 to the x-position
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      //Removing the tail,
      //If the snake ahs eating the food, its body will extend by 1 unit
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    //random display the food
    food = [
      randomGen.nextInt(sqrPerRow),
      randomGen.nextInt(sqpPerCol),
    ];
  }

  bool checkGameOver() {
    //Check if the head collides in the body
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= sqpPerCol ||
        snake.first[0] < 0 ||
        snake.first[0] > sqrPerRow) {
      return true;
    }

    // Check if the head collides in the wall
    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    //Pop-up an alert dialog to display the score and flat button to exit the alert dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text(
              'Score: ${snake.length - 2}',
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              //Add a up & down -> on click drag
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              //Add a left & right -> on click drag
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: AspectRatio(
                ///Set no. of sqrs per row over no. of sqrs per column
                ///Add +5 to some bounderies per widgets
                aspectRatio: sqrPerRow / (sqpPerCol + 5),
                child: GridView.builder(
                  //Disable scroll up & down
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sqrPerRow,
                  ),
                  //item count 20 * 40 = 800 circles in whole screen.
                  itemCount: sqrPerRow * sqpPerCol,

                  /// itemBuilder is where we draw each child widget
                  /// each itemBuilder function will be executed each child.
                  /// starting from zero (upper-left corner)
                  itemBuilder: (BuildContext context, int index) {
                    var color;
                    var x = index % sqrPerRow; // get the x-position
                    var y = (index / sqrPerRow).floor(); // get the y-position

                    bool isSnakeBody = false;
                    for (var pos in snake) {
                      if (pos[0] == x && pos[1] == y) {
                        isSnakeBody = true;
                        break;
                      }
                    }

                    //Set first the colors indicators for head and body of the snake
                    //And also the color of the food
                    //set all of this on the top most left corner [[0,0], [0,1]]
                    if (snake.first[0] == x && snake.first[1] == y) {
                      color = Colors.green;
                    } else if (isSnakeBody) {
                      color = Colors.green[200];
                    } else if (food[0] == x && food[1] == y) {
                      color = Colors.red;
                    } else {
                      color = Colors.grey[800];
                    }

                    return Container(
                      margin: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  //If isPlaying is true, then text = 'End' & color = red
                  //If false, then text = 'Start' & color = blue
                  color: isPlaying ? Colors.red : Colors.blue,
                  child: Text(
                    isPlaying ? 'End' : 'Start',
                    style: fontStyle,
                  ),
                  onPressed: () {
                    // If isPlaying is true, then change isPlaying to false,
                    // Else call the startGame() function
                    if (isPlaying) {
                      isPlaying = false;
                    } else {
                      startGame();
                    }
                  },
                ),
                Text(
                  'Score: ${snake.length - 2}',
                  style: fontStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
