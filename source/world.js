'use strict';

var THREE = require('three');
var Utils = require('./utils');
var Voxel = require('./voxel');

/*
  A game world of size N has 6 faces corresponding to the 6 faces of a cube.
  Each face has a 2D NxN array.

  Movement between faces happens as you would expect on a cube: moving up from 0
  goes to 5, moving right from 0 goes to 4 etc.

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
    this.mesh            = this._makeWorldMesh();
    this.lights          = this._makeLights();
    this._availableTiles = this._setupAvailableTiles();
    this._occupiedTiles  = this._setupOccupiedTiles();
  }

  static position2to3(position2, faceIndex, up) {
    let a = ((position2[0] + 1) * World.TILE_SIZE) - (World.TILE_SIZE / 2) - (World.MESH_SIZE / 2);
    let b = ((position2[1] + 1) * World.TILE_SIZE) - (World.TILE_SIZE / 2) - (World.MESH_SIZE / 2);
    let c = (World.TILE_SIZE / 2) + (World.MESH_SIZE / 2);

    let position3  = [];
    let faceVector = this.faceIndexToVector(faceIndex);
    let cross      = faceVector.clone().cross(up).negate();

    this._fillDimension(cross,      position3, a, 1);
    this._fillDimension(up,         position3, b, 2);
    this._fillDimension(faceVector, position3, c, 3);

    return position3;
  }

  static faceIndexToVector(face) {
    let points = ({
      0: [0, 1, 0],
      1: [0, 0, -1],
      2: [-1, 0, 0],
      3: [0, 0, 1],
      4: [1, 0, 0],
      5: [0, -1, 0]
    })[face];

    return new THREE.Vector3(...points);
  }

  static vectorToFaceIndex(vector) {
    return ({
      '0,1,0':  0,
      '0,0,-1': 1,
      '-1,0,0': 2,
      '0,0,1':  3,
      '1,0,0':  4,
      '0,-1,0': 5,
    })[vector.toArray()];
  }

  static _fillDimension(vector3, position3, scalar, expectedLength = null) {
    if (vector3.x !== 0) position3[0] = scalar * vector3.x;
    if (vector3.y !== 0) position3[1] = scalar * vector3.y;
    if (vector3.z !== 0) position3[2] = scalar * vector3.z;

    if (expectedLength && position3.filter(Boolean).length !== expectedLength) {
      throw new Error('Something went wrong during position translation.');
    }
  }

  // TODO(maros): Make this not have to take `camera` but just `up` vector.
  nextFaceVector(direction, camera) {
    let up        = camera.up.clone();
    let target    = this.mesh.position.clone().sub(camera.position).normalize();
    let position  = null;

    if (direction === 'up')    position = up;
    if (direction === 'right') position = target.clone().cross(up);
    if (direction === 'down')  position = camera.up.clone().multiplyScalar(-1);
    if (direction === 'left')  position = target.clone().cross(up).negate();

    if (position === null) {
      throw new Error('Something went wrong in the nextFaceVector function.');
    }

    return position;
  }

  // TODO(maros): Make this not modify `meshPosition` in place.
  updateMeshPosition(meshPosition, direction, camera) {
    let position = this.nextFaceVector(direction, camera);
    position.multiplyScalar(this.constructor.TILE_SIZE);
    meshPosition.add(position);
  }

  positionOutOfBounds(position) {
    return position[0] < 0 ||
           position[0] >= this.constructor.GAME_SIZE ||
           position[1] < 0 ||
           position[1] >= this.constructor.GAME_SIZE;
  }

  wrapPosition(position) {
    position[0] = (position[0] + this.constructor.GAME_SIZE) % this.constructor.GAME_SIZE;
    position[1] = (position[1] + this.constructor.GAME_SIZE) % this.constructor.GAME_SIZE;
  }

  nextFace(direction, camera) {
    return this.constructor.vectorToFaceIndex(this.nextFaceVector(direction, camera));
  }

  nextPosition(direction, position) {
    if (direction === 'up')    position[1] -= 1;
    if (direction === 'right') position[0] += 1;
    if (direction === 'down')  position[1] += 1;
    if (direction === 'left')  position[0] -= 1;

    let outside = this.positionOutOfBounds(position);

    if (outside) {
      this.wrapPosition(position);
    }

    return outside;
  }

  spawnFood() {
    return this._spawn('food');

  }

  spawnPoison() {
    return this._spawn('poison');
  }

  voxelAt(position3) {
    return this._occupiedTiles[position3.toString()];
  }

  removeVoxel(voxel) {
    let position3 = voxel.mesh.position.toArray();
    this._availableTiles.add(position3);
    return this._occupiedTiles.delete(position3);
  }

  _makeWorldMesh() {
    return Utils.makeVoxelMesh(this.constructor.MESH_SIZE, 0xa5c9f3);
  }

  _makeFoodMesh(position) {
    return Utils.makeVoxelMesh(this.constructor.TILE_SIZE, 0x7fdc50, position);
  }

  // Returns a voxel that will occupy a random tile on the world. If the world
  // is full, it returns `undefind`.
  _spawn(type) {
    if (this._noFreeTiles()) {
      return;
    }

    let position3 = this._popAvailableTile();
    let mesh      = this._makeFoodMesh(position3);
    let voxel     = new Voxel(type, mesh);

    this._occupyTile(position3, voxel);

    return voxel;
  }

  _makeLights() {
    let lights = [
      new THREE.PointLight(0xffffff, 2),
      new THREE.PointLight(0xffffff, 2)
    ];

    let distance = this.constructor.MESH_SIZE * 1.5;

    lights[0].position.set(distance, distance, distance);
    lights[1].position.set(-distance, -distance, -distance);

    return lights;
  }

  _setupAvailableTiles() {
    let positions = [];

    Utils.times(World.FACES, faceIndex => {
      Utils.times(World.GAME_SIZE, x => {
        Utils.times(World.GAME_SIZE, y => {
          let up = Utils.adjacentUnitVector(World.faceIndexToVector(faceIndex));
          let position3 = this.constructor.position2to3([x, y], faceIndex, up);
          positions.push(position3);
        });
      });
    });

    return new Set(Utils.shuffle(positions));
  }

  _setupOccupiedTiles() {
    return new Map();
  }

  _validateVoxelType(voxel) {
    if (!voxel || !['food', 'poison', 'snake'].includes(voxel.type)) {
      throw new Error(`Invalid voxel: ${voxel}`);
    }
  }

  _occupyTile(position3, voxel) {
    this._validateVoxelType(voxel);
    this._occupiedTiles[position3.toString()] = voxel;
  }

  _noFreeTiles() {
    return this._availableTiles.size === 0;
  }

  _popAvailableTile() {
    let item = this._availableTiles.values().next().value;
    this._availableTiles.delete(item);
    return item;
  }
}

World.FACES     = 6;
World.GAME_SIZE = 16;
World.MESH_SIZE = 200;
World.TILE_SIZE = World.MESH_SIZE / World.GAME_SIZE;

module.exports = World;
