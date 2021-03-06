const assert                 = require('assert');
const THREE                  = require('three');
const Const                  = require('./const');
const getUnitVectorDimension = require('./utils/get-unit-vector-dimension');
const to3Array               = require('./utils/to-3-array');
const { Node }               = require('./graph');

class Voxel extends Node {
  constructor(position, mesh = null, type = 'tile') {
    super();

    this.position = to3Array(position);
    this.mesh     = mesh;
    this.type     = type;
    this.face     = this._findFaceVector(this.position);
    this.disabled = new Set();
    this._next    = new Map();
  }

  static middleVoxel(face) {
    face = face.clone();
    face.multiplyScalar((Const.MESH_SIZE + Const.TILE_SIZE) / 2);

    for (let dimension of 'xyz') {
      if (face[dimension] === 0) {
        face[dimension] = (((Const.GAME_SIZE + 1) * Const.TILE_SIZE) - Const.MESH_SIZE) / 2;
      }
    }

    return face;
  }

  static at(position, { create = false } = {}) {
    const key = to3Array(position).toString();
    let voxel = this.VOXEL_CACHE.get(key);

    if (!voxel) {
      assert(create, `Unknown voxel requested at ${key}`);
      voxel = new Voxel(position);
      this.VOXEL_CACHE.set(key, voxel);
    }

    return voxel;
  }

  toString() {
    return this.position.toString();
  }

  next(direction) {
    let key   = to3Array(direction).toString();
    let voxel = this._next.get(key);

    assert(voxel, `Could not find next vector using direction ${key}`);
    return voxel;
  }

  // TODO(maros): Rename this to `next` and just use everywhere.
  nextWithDirection(direction) {
    const next = this.next(direction);

    if (this.face !== next.face) {
      direction = next.directionTo(this, { sourcePlane: true }).negate();
    }

    return [next, direction];
  }

  directionTo(voxel, options={}) {
    let sourcePlane = options.sourcePlane === undefined ? true : options.sourcePlane;

    let v1 = new THREE.Vector3(...this.position);
    let v2 = new THREE.Vector3(...voxel.position);

    let direction = v2.sub(v1);

    if (sourcePlane) {
      // In the case where we move from one face to another, we end up with a
      // direction that is not a unit vector. E.g. (1,1,0) instead of (1,0,0). We
      // use info about the face we are on to pretend the target voxel is on the
      // same face as far as direction is concerned.
      direction[getUnitVectorDimension(this.face)] = 0;
    } else {
      if (direction.length() === Math.sqrt(2 * Const.TILE_SIZE * Const.TILE_SIZE)) {
        direction = this.face.clone();
        direction.negate();
      }
    }

    direction.normalize();

    return direction;
  }

  adjacentTo(voxel) {
    let v1 = new THREE.Vector3(...this.position);
    let v2 = new THREE.Vector3(...voxel.position);
    let distance = v1.distanceTo(v2);
    return distance === Const.TILE_SIZE ||
           distance === Math.sqrt(2 * Const.TILE_SIZE * Const.TILE_SIZE);
  }

  connectTo(voxel) {
    if (!this.adjacentTo(voxel)) {
      return;
    }

    // TODO(maros): Investigate `adjacent` vs `_next`. Why do we need both?
    this._connectNext(voxel);
    this._connectAdjacent(voxel);
  }

  disable(type) {
    for (let neighbor of this.adjacent) {
      neighbor.adjacent.delete(this);
      neighbor.disabled.add(this);
      this.disabled.add(neighbor);
    }

    this.type = type;
    this.adjacent.clear();
  }

  enable() {
    for (let neighbor of this.disabled) {
      neighbor.adjacent.add(this);
      neighbor.disabled.delete(this);
      this.adjacent.add(neighbor);
    }

    this.type = 'tile';
    this.disabled.clear();
  }

  _connectNext(voxel) {
    let direction = this.directionTo(voxel);
    this._next.set(to3Array(direction).toString(), voxel);
  }

  _connectAdjacent(voxel) {
    this.adjacent.add(voxel);
    voxel.adjacent.add(this);
  }

  // TODO(maros): This is not saving references to the actual face vectors from
  // the world class but creating ones that resemble them. Consider fixing this.
  _findFaceVector(position) {
    let facePosition = [0, 0, 0];
    let distance     = Const.MESH_SIZE / 2 + (Const.TILE_SIZE / 2);

    position.forEach((dimension, index) => {
      if (Math.abs(dimension) === distance) {
        facePosition[index] = dimension / distance;
      }
    });

    return new THREE.Vector3(...facePosition);
  }
}

Voxel.VOXEL_CACHE = new Map();

module.exports = Voxel;
