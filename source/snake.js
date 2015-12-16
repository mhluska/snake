'use strict';

var World = require('./world.js');

module.exports = class Snake {
  constructor(world) {
    this.world = world;

    // Possible positions are on a 2D array of size (N-1)x(N-1) for game size N.
    this.position = [Math.floor(World.GAME_SIZE/ 2), Math.floor(World.GAME_SIZE / 4)];

    // Possible faces are [0, 1, 2, 3, 4, 5, 6]
    this.face = 4;

    // Possible directions are ['up', 'right', 'down', 'left']
    this._direction = 'up';
  }

  get direction() {
    return this._direction;
  }

  set direction(val) {
    if (!['up', 'right', 'down', 'left'].includes(val)) return;
    if (['up', 'down'].includes(val) && ['up', 'down'].includes(this._direction)) return;
    if (['left', 'right'].includes(val) && ['left', 'right'].includes(this._direction)) return;

    this._direction = val;
  }

  move() {
    [this.position, this.face] = this.world.nextPosition(this.position, this.face, this.direction);
  }
};
