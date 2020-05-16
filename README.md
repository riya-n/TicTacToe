# Tic Tac Toe
An implementation of a one player Tic Tac Toe against a computer AI.

## Description: 
I’ve implemented the classic game of Tic Tac Toe as a one player game against the computer, where the player is assumed to move when the prompt “Your Turn” is given. The game will count your score, and will also allow you to clear the board. The computer AI is designed such that it makes the move that would be the best response given the player’s move, assuming that the player too is playing optimally. This has been done using an algorithm known as the minimax algorithm, which recursively chooses the optimal move for the computer based on which strategy minimises the maximum loss. Since the computer moves optimally, if the player plays optimally as well, they will at best tie with the computer. Thus, their score will increase when the game ends in a tie. The sounds used when winning (tied game) and losing are from Super Mario Bros.
