'use strict';

var THREE = require('three');
var Voxel = require('./voxel');
var Const = require('./const');

var { adjacentUnitVector, makeVoxelMesh, shuffle, times, combinations } = require('./utils');

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
    this._faceVectors    = this._setupFaceVectors();
    this._voxelMap       = this._setupGraph(this._faceVectors);
    this._availableTiles = this._setupAvailableTiles();
    this._occupiedTiles  = new Map();
  }

  static adjacentPositions(position2, faceVector) {
    let [x, y] = position2;
    let adjacent = [
      [x + 1, y],
      [x - 1, y],
      [x, y - 1],
      [x, y + 1]
    ];

    return adjacent.map(p => this.position2to3(p, faceVector));
  }

  static position2to3(position2, faceVector, up = null) {
    // We need to provide an arbitrary `up` vector.
    if (!up) {
      up = adjacentUnitVector(faceVector);
    }

    let a = ((position2[0] + 1) * Const.TILE_SIZE) - (Const.TILE_SIZE / 2) - (Const.MESH_SIZE / 2);
    let b = ((position2[1] + 1) * Const.TILE_SIZE) - (Const.TILE_SIZE / 2) - (Const.MESH_SIZE / 2);
    let c = (Const.TILE_SIZE / 2) + (Const.MESH_SIZE / 2);

    let position3 = [];
    let cross     = faceVector.clone().cross(up).negate();

    this._fillDimension(cross,      position3, a, 1);
    this._fillDimension(up,         position3, b, 2);
    this._fillDimension(faceVector, position3, c, 3);

    return position3;
  }

  static _fillDimension(vector3, position3, scalar, expectedLength = null) {
    if (vector3.x !== 0) position3[0] = scalar * vector3.x;
    if (vector3.y !== 0) position3[1] = scalar * vector3.y;
    if (vector3.z !== 0) position3[2] = scalar * vector3.z;

    if (expectedLength && position3.filter(Boolean).length !== expectedLength) {
      throw new Error('Something went wrong during position translation.');
    }
  }

  spawnFood() {
    return this._spawn('food');
  }

  spawnPoison() {
    return this._spawn('poison');
  }

  enable(position) {
    let voxel = Voxel.findOrCreate(position);
    voxel.enable();
    this._unoccopyTile(voxel);
  }

  disable(position) {
    let voxel = Voxel.findOrCreate(position);
    voxel.disable();
    this._occupyTile(voxel.position3, voxel);
  }

  _setupFaceVectors() {
    let positions = [
      [0,  1,  0],
      [0,  0, -1],
      [-1, 0,  0],
      [0,  0,  1],
      [1,  0,  0],
      [0, -1,  0]
    ];

    return positions.map(p => new THREE.Vector3(...p));
  }

  _makeWorldMesh() {
    return makeVoxelMesh(Const.MESH_SIZE, 0xa5c9f3);
  }

  _makeFoodMesh(position) {
    return makeVoxelMesh(Const.TILE_SIZE, 0x7fdc50, position);
  }

  // Returns a voxel that will occupy a random tile on the world. If the world
  // is full, it returns `undefind`.
  _spawn(type) {
    if (this._noFreeTiles()) {
      return;
    }

    let position3 = this._popAvailableTile();
    let mesh      = this._makeFoodMesh(position3);
    let voxel     = Voxel.findOrCreate(position3);

    voxel.mesh = mesh;
    voxel.type = type;

    this._occupyTile(position3, voxel);

    return voxel;
  }

  _makeLights() {
    let lights = [
      new THREE.PointLight(0xffffff, 2),
      new THREE.PointLight(0xffffff, 2)
    ];

    let distance = Const.MESH_SIZE * 1.5;

    lights[0].position.set(distance, distance, distance);
    lights[1].position.set(-distance, -distance, -distance);

    return lights;
  }

  // TODO(maros): Use a generator here.
  _eachTile(callback) {
    for (let faceVector of this._faceVectors) {
      for (let x of times(Const.GAME_SIZE)) {
        for (let y of times(Const.GAME_SIZE)) {
          let position3 = this.constructor.position2to3([x, y], faceVector);
          let adjacent  = this.constructor.adjacentPositions([x, y], faceVector);
          callback(position3, adjacent, faceVector, x, y);
        }
      }
    }
  }

  _position2Edge(position2) {
    let max = Const.GAME_SIZE - 1;
    let [x, y] = position2;
    return x === 0 || y === 0 || x === max || y === max;
  }

  _connectAdjacentPositions(positionA, positionB) {
    let v1 = Voxel.findOrCreate(positionA);
    let v2 = Voxel.findOrCreate(positionB);
    v1.connectTo(v2);
  }

  _position3OutOfFace(vector3, faceVector) {
    let max = (Const.TILE_SIZE * Const.GAME_SIZE / 2) + (Const.TILE_SIZE / 2);

    // TODO(maros): Convert to util method.
    for (let dimension of 'xyz') {
      if (faceVector[dimension] === 0) {
        if (Math.abs(vector3[dimension]) >= max) {
          return true;
        }
      }
    }

    return false;
  }

  _setupGraph(faceVectors) {
    // Connect voxels on same faces.
    this._eachTile((position3, adjacent, faceVector) => {
      adjacent.forEach(adj => {
        let adjVector = new THREE.Vector3(...adj);
        if (this._position3OutOfFace(adjVector, faceVector)) {
          // TODO(maros): Convert to util method.
          for (let dimension of 'xyz') {
            if (faceVector[dimension] !== 0) {
              adjVector[dimension] -= (faceVector[dimension] * Const.TILE_SIZE);
            }
          }
        }

        this._connectAdjacentPositions(adjVector.toArray(), position3);
      });
    });
  }

  _setupAvailableTiles() {
    let positions = [];
    this._eachTile(position3 => { positions.push(position3); });
    return new Set(shuffle(positions));
  }

  _validateVoxelType(voxel) {
    if (!voxel || !['food', 'poison', 'snake', 'tile'].includes(voxel.type)) {
      throw new Error(`Invalid voxel: ${voxel}`);
    }
  }

  _occupyTile(position3, voxel) {
    this._validateVoxelType(voxel);
    this._occupiedTiles[position3.toString()] = voxel;
  }

  _unoccopyTile(voxel) {
    this._validateVoxelType(voxel);
    this._availableTiles.add(voxel.position3);
    delete this._occupiedTiles[voxel.position3];
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

module.exports = World;
