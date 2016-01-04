'use strict';

var THREE = require('three');
var World = require('./world');
var Utils = require('./utils');

module.exports = class Snake {
  constructor(world, camera) {
    // Possible positions are on a 2D array of size (N-1)x(N-1) for game size N.
    this.position = [Math.floor(World.GAME_SIZE / 2), Math.floor(World.GAME_SIZE / 4)];
    this.prevPosition = null;

    // Possible faces are [0, 1, 2, 3, 4, 5, 6].
    this.face = 3;
    this.prevFace = null;

    // Default snake size.
    this.size = 6;
    this.mesh = this._makeMeshGroup(this.size, this.position, this.face, camera);

    // Possible directions are ['up', 'right', 'down', 'left'].
    this._direction = 'up';
    this._camera = camera;
    this._world = world;
  }

  get direction() {
    return this._direction;
  }

  set direction(val) {
    if (!['up', 'right', 'down', 'left'].includes(val)) return;

    if (['up', 'down'].includes(val)    && ['up', 'down'].includes(this._direction))    return;
    if (['left', 'right'].includes(val) && ['left', 'right'].includes(this._direction)) return;

    this._direction = val;
  }

  move(newFaceCallback) {
    this.prevPosition = this.position;

    let prevFace = this.face;
    let outside  = this._world.nextPosition(this.direction, this.position);

    if (outside) {
      this.face = this._world.nextFace(this.direction, this._camera);
    }

    let newPosition = this._updateMeshPosition();

    if (prevFace !== this.face) {
      this.prevFace = prevFace;
      newFaceCallback(this.prevFace, this.face, this.direction);
      newPosition = this._updateMeshPosition();
    }

    let voxel = this._world.voxelAt(newPosition);
    this._eat(voxel);

    return voxel;
  }

  _makeVoxelMesh(position3) {
    return Utils.makeVoxelMesh(World.TILE_SIZE, 0x9586de, position3);
  }

  _makeMeshGroup(size, position, face, camera) {
    let group     = new THREE.Object3D();
    let position3 = World.position2to3(position, face, camera.up);

    position3[1] *= -1;

    Utils.times(size, () => {
      group.add(this._makeVoxelMesh(position3));
      position3[1] -= World.TILE_SIZE;
    });

    return group;
  }

  _updateMeshPosition() {
    if (![this.mesh, this._direction, this._camera].every(Boolean)) {
      throw new Error('Mesh, direction or camera are not initialized.');
    }

    let head         = this.mesh.children[0];
    let lastPosition = head.position.clone();

    this._world.updateMeshPosition(head.position, this._direction, this._camera);

    for (let i = 1; i < this.size; i += 1) {
      let piece = this.mesh.children[i];
      let tempPosition = piece.position.clone();
      piece.position.copy(lastPosition);
      lastPosition = tempPosition;
    }

    return head.position.toArray();
  }

  _eat(voxel) {
    if (!voxel) return;

    if (voxel.type === 'food') {
      this._world.removeVoxel(voxel);
      this.mesh.add(this._makeVoxelMesh());
      this.size += 1;
    }
  }
};
