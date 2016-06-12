'use strict';

let THREE                  = require('three');
let Voxel                  = require('./voxel');
let Const                  = require('./const');
let times                  = require('./utils/times');
let shuffle                = require('./utils/shuffle');
let makeVoxelMesh          = require('./utils/make-voxel-mesh');
let getUnitVectorDimension = require('./utils/get-unit-vector-dimension');
let position2to3           = require('./utils/position2-to-3.js');

class World {
  constructor() {
    this.mesh            = this._makeWorldMesh();
    this._faceVectors    = this._setupFaceVectors();
    this._availableTiles = this._setupAvailableTiles();
    this._occupiedTiles  = new Map();

    this._setupGraph();
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

  disable(position, type) {
    let voxel = Voxel.findOrCreate(position);
    voxel.disable(type);
    this._occupyTile(voxel.position, voxel);
  }

  _adjacentPositions(x, y, faceVector) {
    const adjacent = [
      [x + 1, y],
      [x - 1, y],
      [x, y - 1],
      [x, y + 1]
    ];

    return adjacent.map(p => position2to3(p[0], p[1], faceVector));
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
    return makeVoxelMesh(Const.MESH_SIZE, Const.Colors.WORLD);
  }

  _makeFoodMesh(position) {
    let mesh = makeVoxelMesh(Const.TILE_SIZE, Const.Colors.FOOD, position);

    // This pushes the food mesh into the world to give the appearance of half
    // the height of the snake. We also reduce the scale by a fraction to avoid
    // visual issues with food items on world edges.
    let voxel = Voxel.findOrCreate(mesh.position.toArray());
    let offset = voxel.face.clone().negate().multiplyScalar(Const.TILE_SIZE / 2);
    mesh.scale.subScalar(0.01);
    mesh.position.add(offset);

    return mesh;
  }

  // Returns a voxel that will occupy a random tile on the world. If the world
  // is full, it returns `undefind`.
  _spawn(type) {
    if (this._noFreeTiles()) {
      return;
    }

    let position = this._popAvailableTile();
    let mesh     = this._makeFoodMesh(position);
    let voxel    = Voxel.findOrCreate(position);

    voxel.mesh = mesh;
    voxel.type = type;

    this._occupyTile(position, voxel);

    return voxel;
  }

  *_eachPosition() {
    for (let faceVector of this._faceVectors) {
      for (let x of times(Const.GAME_SIZE)) {
        for (let y of times(Const.GAME_SIZE)) {
          let position = position2to3(x, y, faceVector);
          let adjacent = this._adjacentPositions(x, y, faceVector);
          yield [position, adjacent, faceVector, x, y];
        }
      }
    }
  }

  _connectAdjacentPositions(positionA, positionB) {
    let v1 = Voxel.findOrCreate(positionA);
    let v2 = Voxel.findOrCreate(positionB);
    v1.connectTo(v2);
  }

  _positionOutOfFace(vector3, faceVector) {
    const max = (Const.TILE_SIZE * Const.GAME_SIZE / 2) + (Const.TILE_SIZE / 2);

    for (let dimension of 'xyz') {
      if (faceVector[dimension] === 0 && Math.abs(vector3[dimension]) >= max) {
        return true;
      }
    }

    return false;
  }

  _setupGraph() {
    for (let [position, adjacent, faceVector] of this._eachPosition()) {
      adjacent.forEach(adj => {
        let adjVector = new THREE.Vector3(...adj);

        if (this._positionOutOfFace(adjVector, faceVector)) {
          let dimension = getUnitVectorDimension(faceVector);
          adjVector[dimension] -= (faceVector[dimension] * Const.TILE_SIZE);
        }

        this._connectAdjacentPositions(adjVector.toArray(), position);
      });
    }
  }

  _setupAvailableTiles() {
    return new Set(shuffle(Array.from(this._eachPosition()).map(el => el[0])));
  }

  _occupyTile(position, voxel) {
    this._occupiedTiles[position.toString()] = voxel;
  }

  _unoccopyTile(voxel) {
    this._availableTiles.add(voxel.position);
    delete this._occupiedTiles[voxel.position];
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
