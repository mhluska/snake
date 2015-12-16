'use strict';

// var THREE = require('three');

/*
  A game world of size N has 6 faces corresponding to the 6 faces of a cube.
  Each face has a 2D NxN array.

  Movement between faces happens as you would expect on a cube: moving up from 0
  goes to 6, moving right from 0 goes to 5 etc.

           . . .
           . 0 .
   . . . . . . . . .
   . 1 . 2 . 3 . 4 .
   . . . . . . . . .
           . 5 .
           . . .
*/

class World {
  constructor() {
    this._faceAdjacency = {
      0: { up: 1, right: 4, down: 3, left: 2 },
      1: { up: 0, right: 2, down: 5, left: 4 },
      2: { up: 0, right: 3, down: 5, left: 1 },
      3: { up: 0, right: 4, down: 5, left: 2 },
      4: { up: 0, right: 1, down: 5, left: 3 },
      5: { up: 3, right: 4, down: 1, left: 2 }
    };
  }

  positionOutOfBounds(position) {
    return position[0] < 0 ||
           position[0] >= World.GAME_SIZE ||
           position[1] < 0 ||
           position[1] >= World.GAME_SIZE;
  }

  wrapPosition(position) {
    position[0] = (position[0] + World.GAME_SIZE) % World.GAME_SIZE;
    position[1] = (position[1] + World.GAME_SIZE) % World.GAME_SIZE;
    return position;
  }

  nextFace(face, direction) {
    return this._faceAdjacency[face][direction];
  }

  nextPosition(position, face, direction) {
    switch (direction) {
      case 'up':
        position = [position[0], position[1] - 1];
        break;
      case 'right':
        position = [position[0] + 1, position[1]];
        break;
      case 'down':
        position = [position[0], position[1] + 1];
        break;
      case 'left':
        position = [position[0] - 1, position[1]];
        break;
    }

    if (this.positionOutOfBounds(position)) {
      position = this.wrapPosition(position);
      face     = this.nextFace(face, direction);
    }

    return [position, face];
  }
}

World.GAME_SIZE = 10;

module.exports = World;
