'use strict';

let assert            = require('assert');
let THREE             = require('three');
let Const             = require('./const');
let Voxel             = require('./voxel');
let Queue             = require('./queue');
let makeVoxelMesh     = require('./utils/make-voxel-mesh');
let times             = require('./utils/times');
let adjacentPositions = require('./utils/adjacent-positions');
let assertTruthy      = require('./utils/assert-truthy');
let { Graph }         = require('./graph');

module.exports = class Snake {
  constructor(world, direction, face) {
    this._path      = new Queue();
    this._autoMove  = true;
    this._direction = direction;
    this._world     = world;

    this.face = face;
    this.size = 6;
    this.mesh = this._makeMeshGroup(this.size);
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
    return this._direction;
  }

  set direction(vector) {
    assert(vector.length() === 1, 'Non unit vector passed to direction setter.');

    // Disallow movement in opposite directions.
    if (vector.dot(this._direction) !== 0) {
      return;
    }

    this._direction.copy(vector);
    this._autoMove = false;
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
    assertTruthy(this.position, this._direction);

    let nextVoxel = Voxel.findOrCreate(this.position).next(this._direction);
    return this._updateSnakeMeshPosition(nextVoxel.position);
  }

  // TODO(maros): Remove magic color code.
  _makeVoxelMesh(position) {
    return makeVoxelMesh(Const.TILE_SIZE, 0x9586de, position);
  }

  _makeMeshGroup(size) {
    // TODO(maros): Make this not magic.
    let position = [-43.75, -6.25, 106.25];
    let group    = new THREE.Object3D();

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
  // and `this._direction`. Use a setter to enforce it.
  _updateSnakeMeshPosition(position) {
    assertTruthy(this.position, this.mesh, this.head);
    assert(adjacentPositions(position, this.head.position.toArray()),
      'Attempting to update mesh to non-adjacent position.');

    let currentVoxel = Voxel.findOrCreate(this.position);
    let targetVoxel  = Voxel.findOrCreate(position);

    this._direction = currentVoxel.directionTo(targetVoxel, { sourcePlane: false });
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
