# Tetris-Assembly

## 1. Milestone 1: Draw the scene (static; nothing moves yet)
- a) Draw the three walls of the playing area. **[Done]**
- b) Within the playing area, draw a grid background that shows where the blocks of each tetromino will be aligned (e.g., similar to the checkerboard grid in Figure 5.1). **[Done]**
- c) Draw the first tetromino (at some initial location). **[Done]**

## 2. Milestone 2: Implement movement and other controls
- a) Move the tetromino in response to the W, A, S and D keys (to make the tetromino move left and right, rotate, and drop). **[Done]**
- b) Re-paint the screen in a loop to visualize movement. **[Done]**
- c) Allow the player to quit the game. **[Done]**

## 3. Milestone 3: Implement collision detection
- a) When the tetromino moves against the left or right side wall of the playing area, keep it in the same location. **[Done]**
- b) If the tetromino lands on top of another piece or on the bottom of the playing area, leave it there and generate a new piece at the top of the playing area. **[Needs Gravity]**
- c) Remove any lines of blocks that result from dropping a piece into the playing area. **[Nothing Yet]**

## 4. Milestone 4: Game features (one of the combinations below)
- a) 5 easy features
- b) 3 easy features and 1 hard feature
- c) 1 easy feature and 2 hard features
- d) 3 hard features

## 5. Milestone 5: More game features (one of the combinations below)
Note that the combinations below denote the total number of features in your game.
- a) 8 easy features
- b) 6 easy features and 1 hard feature
- c) 4 easy features and 2 hard features
- d) 2 easy features and 3 hard features
- e) 1 easy feature and 4 hard features
- f) 5 (or more) hard features

### Easy Features
Easy features do not, typically, require significant changes to existing code or data structures. Instead, they are mostly “adding on” to your program. The easy features below are numbered so that you can refer to them by their number in the preamble.

1. Implement gravity, so that each second that passes will automatically move the tetromino down one row.
2. Assuming that gravity has been implemented, have the speed of gravity increase gradually over time, or after the player completes a certain number of rows.
3. When the player has reached the “game over” condition, display a Game Over screen in pixels on the screen. Restart the game if a “retry” option is chosen by the player. Retry should start a brand new game (no state is retained from previous attempts).
4. Add sound effects for different conditions like rotating and dropping Tetrominoes, and for winning and game over.
5. If the player presses the keyboard key `p`, display a “Paused” message on screen until they press `p` a second time, at which point the original game will resume.
6. Add levels to the game that are triggered after the player completed a certain number of rows, where the next level is more difficult in some way than the previous one.
7. Start the level with 5 random unfinished rows on the bottom of the playing field.
8. Show an outline of where the piece will end up if you drop it (see Figure 2.2).
9. Add a second playing field that is controlled by a second player using different keys.
10. Assuming that you’ve implemented the score feature (see the hard features) and the ability to start a new game (see easy features), track and display the highest score so far. This score needs to be displayed in pixels, not on the console display.
11. Assuming that you’ve implemented the full set of Tetrominoes, make sure that each tetromino type is a different color.
12. Have a panel on the side that displays a preview of the next tetromino that will appear (see Figure 2.1a).
13. Assuming that you’ve implemented the previous feature, extend it to show a preview of the next 4-5 pieces.
14. Implement the “save” feature, where you can save the current piece on the side instead of playing it. The game would skip to the next piece and then allow you to retrieve the saved piece later in the game.

### Hard Features
Hard features require more substantial changes to your code. This may be due to significant changes to existing code or adding a significant amount of new code. The hard features below are numbered so that you can refer to them by their number in the preamble.

1. Track and display the player’s score, which is based on how many lines have been completed so far. This score needs to be displayed in pixels, not on the console display.
2. Implement the full set of Tetrominoes.
3. Create menu screens for things like level selection, a scoreboard of high scores, etc. (assumes you have completed at least one of those hard features).
4. Add some animation to lines when they are completed (e.g. make them go poof).
5. Play the Tetris theme music (aka ”Korobeiniki”) in the background while playing the game.
6. Have special blocks randomly occur in some Tetrominoes that do something special when they are in a completed line (e.g. they destroy the line above and below as well).
7. Add a power-up of some kind that is activated on certain conditions (e.g., when you complete 4 rows at once, when you complete 20 rows). Each power-up would be its own easy or hard feature and would be classified according to the TA’s discretion.
8. Implement the wall kick feature of SRS, when rotating pieces: [SRS](https://harddrop.com/wiki/SRS). This approach to rotation checks various alternate locations if the rotation would cause the current piece to intersect with the walls or other pieces.

