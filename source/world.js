const THREE                  = require('three');
const assert                 = require('assert');
const Voxel                  = require('./voxel');
const Const                  = require('./const');
const times                  = require('./utils/times');
const shuffle                = require('./utils/shuffle');
const makeVoxelMesh          = require('./utils/make-voxel-mesh');
const getUnitVectorDimension = require('./utils/get-unit-vector-dimension');
const position2to3           = require('./utils/position2-to-3.js');

class World {
  constructor() {
    this.mesh         = this._makeWorldMesh();
    this._faceVectors = this._setupFaceVectors();
    this._positions   = this._setupRandomPositions();

    this._setupGraph();
  }

  spawnFood() {
    return this._spawn('food');
  }

  spawnPoison() {
    return this._spawn('poison');
  }

  enable(position) {
    Voxel.at(position).enable();
  }

  disable(position, type) {
    assert(type, 'Type required to disable voxel');

    let voxel = Voxel.at(position);
    voxel.disable(type);
  }

  reset() {
    for (let [position] of this._eachPosition()) {
      Voxel.at(position).enable();
    }
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
    let voxel = Voxel.at(mesh.position);
    let offset = voxel.face.clone().negate().multiplyScalar(Const.TILE_SIZE / 2);
    mesh.scale.subScalar(0.01);
    mesh.position.add(offset);

    return mesh;
  }

  // Returns a voxel that will occupy a random voxel in the world. If the world
  // is full, it returns `undefind`.
  _spawn(type) {
    if (this._noFreePositions()) {
      return;
    }

    let position = this._popAvailablePosition();
    let mesh     = this._makeFoodMesh(position);
    let voxel    = Voxel.at(position);

    voxel.mesh = mesh;
    voxel.type = type;

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
    let v1 = Voxel.at(positionA);
    let v2 = Voxel.at(positionB);
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

        this._connectAdjacentPositions(adjVector, position);
      });
    }
  }

  _setupRandomPositions() {
    return new Set(shuffle(Array.from(this._eachPosition()).map(el => el[0])));
  }

  _noFreePositions() {
    return this._positions.size === 0;
  }

  _popAvailablePosition() {
    let value, done;
    let iter = this._positions.values();

    do {
      ({ value, done } = iter.next());
    } while (!done && Voxel.at(value).type !== 'tile');

    this._positions.delete(value);
    return value;
  }
}

module.exports = World;
