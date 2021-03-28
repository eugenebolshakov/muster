# What is Muster

This is a clone of the [game
2048](https://en.wikipedia.org/wiki/2048_(video_game) with slightly different
rules. I've called the game "Muster", as in "pass muster", because this is a
test exercise.

## Playing the game

Please run ./start.sh to start the game. This script will attempt to use Docker
to run the app if available, or otherwise will attempt to run it using
Elixir/NodeJS installed on the host.

Once the app is started, please open http://localhost:4000 in the browser to
start the game as player 1, and again in a different browser tab/window to play
as player 2. Any additional web sessions will be spectators who'll be able to
view the game and play once the current game ends. Please use the arrow keys on
your keyword to make a move.

## Ending / restarting the game

The game ends if one of the players wins, looses or leaves (e.g. closes the
browser window). In such case the game can be restarted (press "Restart game")
by any user and another user can join (press "Join") the new game.

## Rules of the game

* The game is played on a 6x6 grid with numbered tiles.
* The game is played by 2 players who take turns to make a single move.
* The game starts with a tile of value 2 placed randomly.
* On each turn players move tiles in one of 4 directions: up, down, left or
  right.
* Each tile slides in the chosen direction as far as possible until it's
  stopped by either another tile or the edge of the grid.
* If two tiles of the same number collide, they are merged into a tile with
  their total value.
* The resulting tile cannot merge with another tile again in the same move.
* If a move causes three consecutive tiles of the same value to slide together,
  only the two tiles farthest along the direction of motion will combine.
* If four spaces in a row or column are filled with tiles of the same value, a
  move parallel to that row/column will combine the first two and last two.
* After every move a new tile of value 1 is randomly added.
* Player who gets a tile of value 2048 wins.
* Player who makes a move after which there is no space to add a new tile
  looses.

## Implementation

The game is written in Elixir and is implemented as an umbrella app with the
"core" of the game and the UI as two separate apps.

The "core" includes the game logic and a process that maintains the current
game in memory.

The UI is implemented using Phoenix LiveView. There is a LiveView process for
every user (which hold the name of the player if the user is playing) and a
separate process that monitors LiveViews of players, so that the game is
stopped if a player leaves.

## Running tests

There are some tests for the "core" app, that can be executed (after the setup
has been performed by ./start.sh):

* Via docker: `docker run --rm -v $PWD:/usr/src/app muster mix test`
* On the host directly: `mix test`

## TODO

* Tests for the UI (some acceptances tests using Wallaby for example).
