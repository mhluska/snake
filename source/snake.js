'use strict';

var World = require('./world.js');
var Voxel = require('./voxel.js');

module.exports = class Snake {
  constructor(world, camera) {
    this.world = world;
    this.voxel = new Voxel();

    // Possible positions are on a 2D array of size (N-1)x(N-1) for game size N.
    this.position = [Math.floor(World.GAME_SIZE/ 2), Math.floor(World.GAME_SIZE / 4)];
    this.prevPosition = null;

    this.voxel.mesh.position.set(...this.world.position2to3(this.position));
    this.voxel.mesh.position.y *= -1;

    // Possible faces are [0, 1, 2, 3, 4, 5, 6]
    this.face = 3;
    this.prevFace = null;

    // Possible directions are ['up', 'right', 'down', 'left']
    this._direction = 'up';
    this._camera = camera;
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

  get mesh() {
    return this.voxel.mesh;
  }

  move(newFaceCallback) {
    this.prevPosition = this.position;

    let prevFace = this.face;
    let outside  = this.world.nextPosition(this.direction, this.position);

    if (outside) {
      this.face = this.world.nextFace(this.direction, this._camera);
    }

    if (prevFace === this.face) {
      this._updateMeshPosition();
    } else {
      this.prevFace = prevFace;
      this._updateMeshPosition();
      newFaceCallback(this.prevFace, this.face, this.direction);
      this._updateMeshPosition();
    }
  }

  _updateMeshPosition() {
    this.world.updateMeshPosition(this.mesh.position, this._direction, this._camera);
  }
};
