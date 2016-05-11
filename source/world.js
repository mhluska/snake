'use strict';

var assert                 = require('assert');
var THREE                  = require('three');
var Voxel                  = require('./voxel');
var Const                  = require('./const');
var times                  = require('./utils/times');
var shuffle                = require('./utils/shuffle');
var makeVoxelMesh          = require('./utils/make-voxel-mesh');
var adjacentUnitVector     = require('./utils/adjacent-unit-vector');
var getUnitVectorDimension = require('./utils/get-unit-vector-dimension');
var position2to3           = require('./utils/position2-to-3.js');

class World {
  constructor() {
    this.mesh            = this._makeWorldMesh();
    this.lights          = this._makeLights();
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

  disable(position) {
    let voxel = Voxel.findOrCreate(position);
    voxel.disable();
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

    let position = this._popAvailableTile();
    let mesh     = this._makeFoodMesh(position);
    let voxel    = Voxel.findOrCreate(position);

    voxel.mesh = mesh;
    voxel.type = type;

    this._occupyTile(position, voxel);

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
          let position = position2to3(x, y, faceVector);
          let adjacent  = this._adjacentPositions(x, y, faceVector);
          callback(position, adjacent, faceVector, x, y);
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
    // Connect voxels on same faces.
    this._eachTile((position, adjacent, faceVector) => {
      adjacent.forEach(adj => {
        let adjVector = new THREE.Vector3(...adj);

        if (this._positionOutOfFace(adjVector, faceVector)) {
          let dimension = getUnitVectorDimension(faceVector);
          adjVector[dimension] -= (faceVector[dimension] * Const.TILE_SIZE);
        }

        this._connectAdjacentPositions(adjVector.toArray(), position);
      });
    });
  }

  _setupAvailableTiles() {
    let positions = [];
    this._eachTile(position => { positions.push(position); });
    return new Set(shuffle(positions));
  }

  _validateVoxelType(voxel) {
    let test = voxel && ['food', 'poison', 'snake', 'tile'].includes(voxel.type);
    let message = `Invalid voxel: ${voxel}`;
    assert(test, message);
  }

  _occupyTile(position, voxel) {
    this._validateVoxelType(voxel);
    this._occupiedTiles[position.toString()] = voxel;
  }

  _unoccopyTile(voxel) {
    this._validateVoxelType(voxel);
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
