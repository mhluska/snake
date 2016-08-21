const THREE                  = require('three');
const assert                 = require('assert');
const Voxel                  = require('./voxel');
const Const                  = require('./const');
const Animation              = require('./animation');
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
    this._positions.add(position);
    Voxel.at(position).enable();
  }

  disable(position, type) {
    assert(type, 'Type required to disable voxel');
    assert(type !== 'food', 'Please use `spawnFood` interface for food type');

    this._positions.delete(position);
    Voxel.at(position).disable(type);
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
    return makeVoxelMesh(Const.MESH_SIZE, { map: this._makeWorldTexture() });
  }

  // TODO(maros): Move this to a util module.
  _makeWorldTexture() {
    const max = 255;
    const size = 84;
    const values = 3;
    const rgb = new Uint8Array(size * size * values);
    const color = Const.Colors.WORLD;

    // 1 in 32 chance to return the `high` value.
    const chance = ({ normal, high }) => {
      return Math.floor(Math.random() * 32) === 0 ? high : normal;
    };

    for (let i of times(size * size)) {

      const shift = chance({ normal: 0, high: 24 });
      const variance = chance({ normal: 32, high: 64 });
      const brightness = max - (Math.random() * variance);

      rgb[(i * values) + 0] = (((color >> 16) & max) * (brightness / max) + shift);
      rgb[(i * values) + 1] = (((color >> 8)  & max) * (brightness / max) + shift);
      rgb[(i * values) + 2] = (((color)       & max) * (brightness / max) + shift);
    }

    const texture = new THREE.DataTexture(rgb, size, size, THREE.RGBFormat);
    texture.needsUpdate = true;

    return texture;
  }

  _makeFoodMesh(position) {
    let mesh = makeVoxelMesh(Const.TILE_SIZE, { color: Const.Colors.FOOD, position: position });

    // This pushes the food mesh into the world to give the appearance of half
    // the height of the snake. We also reduce the scale by a fraction to avoid
    // visual issues with food items on world edges.
    let voxel = Voxel.at(mesh.position);
    let offset = voxel.face.clone().negate().multiplyScalar(Const.TILE_SIZE / 2);
    mesh.scale.setScalar(World.FOOD_SCALE_MAX);
    mesh.position.add(offset);

    return mesh;
  }

  // Returns a voxel that will occupy a random voxel in the world. If the world
  // is full, it returns `undefind`.
  _spawn(type) {
    const position = this._popAvailablePosition();

    if (!position) {
      return;
    }

    const mesh  = this._makeFoodMesh(position);
    const voxel = Voxel.at(position);

    voxel.mesh = mesh;
    voxel.type = type;

    const min = World.FOOD_SCALE_MIN;
    const max = World.FOOD_SCALE_MAX;

    mesh.scale.setScalar(min);

    Animation.add({
      time: 0.5,
      easing: 'easeOut',
      step: (percent) => {
        const scale = Math.min(max, Math.max(min, percent));
        mesh.scale.setScalar(scale);
      }
    });

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
    let v1 = Voxel.at(positionA, { create: true });
    let v2 = Voxel.at(positionB, { create: true });
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

World.FOOD_SCALE_MIN = 0.01;
World.FOOD_SCALE_MAX = 0.99;

module.exports = World;
