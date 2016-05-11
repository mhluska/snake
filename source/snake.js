'use strict';

var assert            = require('assert');
var THREE             = require('three');
var Const             = require('./const');
var World             = require('./world');
var Voxel             = require('./voxel');
var Queue             = require('./queue');
var makeVoxelMesh     = require('./utils/make-voxel-mesh');
var times             = require('./utils/times');
var adjacentPositions = require('./utils/adjacent-positions');
var assertTruthy      = require('./utils/assert-truthy');
var { Graph }         = require('./graph');

module.exports = class Snake {
  constructor(world, direction) {
    this._path      = new Queue();
    this._autoMove  = true;
    this._direction = 'up';
    this._dirVector = direction;
    this._world     = world;

    // TODO(maros): Don't arbitrarily pick face. Use knowledge of what face the
    // camera is looking at.
    this.face = this._world._faceVectors[3];
    this.size = 6;
    this.mesh = this._makeMeshGroup(this.size, this._world, this.face);
  }

  get head() {
    return this.mesh.children[0];
  }

  get tail() {
    return this.mesh.children[this.size - 1];
  }

  get position() {
    return this.head.position.toArray();
  }

  get direction() {
    return this._dirVector;
  }

  set direction(val) {
    if (!['up', 'right', 'down', 'left'].includes(val)) return;
    if (['up', 'down'].includes(val)    && ['up', 'down'].includes(this._direction))    return;
    if (['left', 'right'].includes(val) && ['left', 'right'].includes(this._direction)) return;

    this._dirVector.cross(this.face);

    if (this._direction === 'up'    && val === 'left' ||
        this._direction === 'right' && val === 'up' ||
        this._direction === 'down'  && val === 'right' ||
        this._direction === 'left'  && val === 'down') {

      this._dirVector.negate();
    }

    this._direction = val;
    this._autoMove  = false;
  }

  move() {
    this._world.enable(this.tail.position.toArray());

    let prevHead = this.head.position.clone();
    let position = this._moveAuto() || this._moveManual();

    this._world.disable(prevHead.toArray());

    let voxel = Voxel.findOrCreate(position);
    this._eat(voxel);
    return voxel;
  }

  _moveAuto() {
    if (!this._autoMove) {
      return false;
    }

    if (this._path.empty()) {
      // Find new target.
      let start = Voxel.findOrCreate(this.position);
      let path  = Graph.dijkstra(start, node => node.type === 'food');

      if (!path) {
        return false;
      }

      path.shift();

      if (path.length === 0) {
        return false;
      }

      this._path = new Queue(path);
    }

    return this._updateSnakeMeshPosition(this._path.dequeue().position);
  }

  _moveManual() {
    assertTruthy(this.position, this._dirVector);

    let nextVoxel = Voxel.findOrCreate(this.position).next(this._dirVector);
    return this._updateSnakeMeshPosition(nextVoxel.position);
  }

  // TODO(maros): Remove magic color code.
  _makeVoxelMesh(position) {
    return makeVoxelMesh(Const.TILE_SIZE, 0x9586de, position);
  }

  _makeMeshGroup(size, world, face) {
    let group    = new THREE.Object3D();
    let position = [-43.75, -6.25, 106.25];

    for (let i of times(size)) {
      let meshPosition = [...position];
      meshPosition[1] *= -1;
      meshPosition[1] -= i * Const.TILE_SIZE;

      group.add(this._makeVoxelMesh(meshPosition));
      this._world.disable(meshPosition);
    }

    return group;
  }

  // TODO(maros): This should be the only method that manipulates `this.face`
  // and `this._dirVector`. Use a setter to enforce it.
  _updateSnakeMeshPosition(position) {
    assertTruthy(this.position, this.mesh, this.head);
    assert(adjacentPositions(position, this.head.position.toArray()),
      'Attempting to update mesh to non-adjacent position.');

    let currentVoxel = Voxel.findOrCreate(this.position);
    let targetVoxel  = Voxel.findOrCreate(position);

    this._dirVector = currentVoxel.directionTo(targetVoxel, { sourcePlane: false });
    this.face       = targetVoxel.face;

    for (let i = 0; i < this.size; i += 1) {
      let piece = this.mesh.children[i];
      let tempPosition = piece.position.toArray();
      piece.position.set(...position);
      position = tempPosition;
    }

    return this.head.position.toArray();
  }

  _eat(voxel) {
    if (!voxel) return;

    if (voxel.type === 'food') {
      this._world.disable(voxel);
      this.mesh.add(this._makeVoxelMesh());
      this.size += 1;
    }
  }
};
