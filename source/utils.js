'use strict';

var THREE = require('three');
var Voxel = require('./voxel');
var assert = require('assert');

let times = function* (count) {
  for (let i = 0; i < count; i += 1) {
    yield i;
  }
};

let random = (min, max) => {
  if (arguments.length === 1) {
    max = min;
    min = 0;
  }

  return Math.floor(Math.random() * (max - min)) + min;
};

let adjacentUnitVector = vector3 => {
  assert(vector3.length() === 1, 'Non unit vector passed to adjacentUnitVector.');

  let units = vector3.toArray();
  units.unshift(units.pop());
  return new THREE.Vector3(...units);
};

let adjacentPositions = (positionA, positionB) => {
  return new Voxel(positionA).adjacentTo(new Voxel(positionB));
};

let shuffle = array => {
  for (let index = 0; index < array.length - 1; index += 1) {
    let item        = array[index];
    let randomIndex = random(index + 1, array.length);
    let temp        = array[randomIndex];

    array[randomIndex] = item;
    array[index] = temp;
  }

  return array;
};

let makeVoxelMesh = (size, color, position = null) => {
  var geometry = new THREE.BoxGeometry(size, size, size);
  var material = new THREE.MeshLambertMaterial({ color: color });
  var mesh     = new THREE.Mesh(geometry, material);

  if (position) {
    mesh.position.set(...position);

    // TODO(maros): Remove this side effect.
    Voxel.findOrCreate(position, mesh);
  }

  return mesh;
};

let assertTruthy = () => {

};

module.exports = {
  times,
  random,
  shuffle,
  adjacentUnitVector,
  adjacentPositions,
  makeVoxelMesh,
  assertTruthy
};
